import csv
import datetime
import uuid
import time
from support_sphere.models.public.point_of_interest import PointOfInterest, PointOfInterestType
import typer
import json

from pathlib import Path

from support_sphere.models.public import (UserProfile, People, Cluster, PeopleGroup, Household,
                                          RolePermission, UserRole, UserCaptainCluster, SignupCode,
                                          ResourceType, ResourceCV, Resource, Checklist, ChecklistStep,
                                          ChecklistStepsOrder, Frequency)
from support_sphere.models.auth import User
from support_sphere.repositories.auth import UserRepository
from support_sphere.repositories.base_repository import BaseRepository
from support_sphere.repositories.public import UserProfileRepository, UserRoleRepository, PeopleRepository
from support_sphere.repositories import supabase_client

from support_sphere.models.enums import AppRoles, AppPermissions, OperationalStatus

import logging

DATA_DIRECTORY = Path(__file__).parent / 'resources' / 'data'

logger = logging.getLogger(__name__)

db_init_app = typer.Typer()


def populate_resource_types() -> dict[str, uuid.UUID]:
    """
    Populate resource types to the database.
    """
    resource_types_data = {
        "Durable": "These are physical instruments and devices that help you perform specific tasks, such as repairs, navigation, or building shelters during an emergency.",
        "Consumable": "These are essential supplies, including food, water, and personal hygiene products that are consumed or used up during an emergency.",
        "Skill": "These are the skills and knowledge that individuals or groups should possess or develop in preparation for an emergency."
    }
    resource_types = [
        ResourceType(name=type_name, description=type_description)
        for type_name, type_description in resource_types_data.items()
    ]
    resource_type_uids = {r.name: r.id for r in resource_types}
    BaseRepository.add_all(resource_types)
    return resource_type_uids


def populate_resources(cv_only=False, resource_type_uids: dict[str, uuid.UUID] | None = None):
    """
    Populate resource controlled vocabulary (CV) and resources to the database.
    """
    # Check for the resource_type_uids if cv_only is False
    if not cv_only:
        if not isinstance(resource_type_uids, dict):
            raise ValueError("resource_type_uids must be provided if cv_only is False")

    file_path = DATA_DIRECTORY / 'resources.csv'
    with file_path.open(mode='r', newline='') as file:
        csv_reader = csv.DictReader(file)

        for row in csv_reader:
            resource_cv = ResourceCV(name=row['Item'], description=row['Description'])
            BaseRepository.add(resource_cv)

            if not cv_only:
                resource_type_uid = resource_type_uids.get(row['Category'], None)
                # Check if the resource type exists
                # this is needed so errors are raised early
                if resource_type_uid is None:
                    raise ValueError(f"Resource type with name '{row['Category']}' not found in the database.")
                resource = Resource(
                    resource_type_id=resource_type_uid,
                    resource_cv_id=resource_cv.id
                )
                BaseRepository.add(resource)


def populate_user_details():
    """
        This utility function populates your local supabase database tables with sample data entries.
    """

    all_households = BaseRepository.select_all(Household)

    file_path = DATA_DIRECTORY / 'sample_data.csv'
    with file_path.open(mode='r', newline='') as file:
        csv_reader = csv.DictReader(file)

        for row in csv_reader:
            user_profile = None
            if bool(eval(row['has_profile'])):
                # Create a auth.user with encrypted_password (ONLY FOR LOCAL TESTING)
                supabase_client.auth.sign_up({"email": row['email'], "password": row['username']})
                supabase_client.auth.sign_out()
                user: User = UserRepository.find_by_email(row['email'])

                # Create a user profile
                profile = UserProfile(user=user)
                user_profile = UserProfileRepository.add(profile)

                user_role = UserRole(user_profile=user_profile, role=AppRoles.USER)
                BaseRepository.add(user_role)

            # Create People Entry
            person_detail = People(given_name=row['given_name'], family_name=row['family_name'],
                                   is_safe=bool(eval(row['is_safe'])), needs_help=bool(eval(row['needs_help'])),
                                   accessibility_needs=bool(eval(row['accessibility_needs'])),
                                   user_profile=user_profile)

            person = PeopleRepository.add(person_detail)

            # Create a PeopleGroup Entry
            people_group = PeopleGroup(people=person, household=all_households[-1])
            BaseRepository.add(people_group)
    logger.info("Database Populated Successfully")

def populate_checklists():
    """
    Populate checklists to the database.
    """
    file_path = DATA_DIRECTORY / 'checklists.json'
    with open(file_path) as f:
        data = json.load(f)

    for ch in data['checklists']:
        checklist = Checklist(
            title=ch['title'],
            description=ch['purpose']
        )
        BaseRepository.add(checklist)

        # Add frequency for checklist
        frequency = Frequency(name=ch['frequency']['name'], num_days=ch['frequency']['num_days'])
        BaseRepository.add(frequency)

        # Add steps for checklist
        for idx, st in enumerate(ch['steps']):
            step = ChecklistStep(label=st['step'], description=st['description'])
            BaseRepository.add(step)
            step_order = ChecklistStepsOrder(checklist_id=checklist.id, checklist_step_id=step.id, priority=idx)
            BaseRepository.add(step_order)


@db_init_app.command(help="Setup a dummy cluster and a household")
def populate_cluster_and_household_details():
    # Creating entries in 'Cluster' and 'Household' table.
    cluster = Cluster(name="Cluster1")
    BaseRepository.add(cluster)
    all_clusters = BaseRepository.select_all(Cluster)

    household = Household(cluster=all_clusters[-1], name="Household1")
    BaseRepository.add(household)


def generate_signup_codes(household_id: uuid.UUID):
    """
    Generate random signup code for a household.
    """
    # Generate random signup code
    while True:
        try:
            uid = uuid.uuid4()
            code = uid.hex[:7].upper()
            if BaseRepository.check_exists(SignupCode, 'code', code):
                raise Exception("Code already exists")

            signup_code = SignupCode(code=code, household_id=household_id)
            # Add signup code to the database
            BaseRepository.add(signup_code)
        except Exception as e:
            logger.error(f"Error: {e}... trying again")
            time.sleep(2)
            continue
        break


@db_init_app.command(help="Populate clusters and households based on household data container cluster name and address")
def populate_real_cluster_and_household():
    """
    Populate clusters and households based on household data container cluster name and address.
    During the creation of household, random signup code is also generated using uuid.
    """
    household_data = DATA_DIRECTORY / 'households.csv'
    with household_data.open(mode='r', newline='') as file:
        csv_reader = csv.DictReader(file)

        cluster_uids = {}
        for row in csv_reader:
            # Get and set cluster
            cluster_name = row["CLUSTER"]
            if cluster_name not in cluster_uids:
                cluster = Cluster(name=cluster_name)
                cluster_id = cluster.id
                cluster_uids[cluster_name] = cluster.id

                # Add cluster to the database
                BaseRepository.add(cluster)
            else:
                cluster_id = cluster_uids[cluster_name]

            # Setup household
            household_address = row['ADDRESS']
            household = Household(cluster_id=cluster_id, address=household_address)
            # Add household to the database
            BaseRepository.add(household)

            # Generate random signup code
            generate_signup_codes(household.id)


@db_init_app.command(help="Sanity check for sign-up and sign-in via supabase")
def authenticate_user_signup_signin_signout_via_supabase():
    # The password is stored in an encrypted format in the auth.users table
    response_sign_up = supabase_client.auth.sign_up({"email": "zeta@abc.com", "password": "zetazeta"})
    supabase_client.auth.sign_out()
    response_sign_in = supabase_client.auth.sign_in_with_password({"email": "zeta@abc.com", "password": "zetazeta"})
    supabase_client.auth.sign_out()


def update_user_permissions_roles_by_cluster():
    role_1 = RolePermission(role=AppRoles.ADMIN, permission=AppPermissions.OPERATIONAL_EVENT_READ)
    role_2 = RolePermission(role=AppRoles.ADMIN, permission=AppPermissions.OPERATIONAL_EVENT_CREATE)
    role_3 = RolePermission(role=AppRoles.COM_ADMIN, permission=AppPermissions.OPERATIONAL_EVENT_CREATE)
    role_4 = RolePermission(role=AppRoles.COM_ADMIN, permission=AppPermissions.OPERATIONAL_EVENT_READ)
    role_5 = RolePermission(role=AppRoles.SUBCOM_AGENT, permission=AppPermissions.OPERATIONAL_EVENT_READ)

    BaseRepository.add(role_1)
    BaseRepository.add(role_2)
    BaseRepository.add(role_3)
    BaseRepository.add(role_4)
    BaseRepository.add(role_5)

    user = UserRepository.find_by_email('adam.abacus@example.com')
    user_role = UserRoleRepository.find_by_user_profile_id(user.id)
    user_role.role = AppRoles.SUBCOM_AGENT
    BaseRepository.add(user_role)

    all_clusters = BaseRepository.select_all(Cluster)
    cluster_role = UserCaptainCluster(cluster=all_clusters[-1], user_role=user_role)
    BaseRepository.add(cluster_role)

    user = UserRepository.find_by_email('beth.bodmas@example.com')
    user_role = UserRoleRepository.find_by_user_profile_id(user.id)
    user_role.role = AppRoles.COM_ADMIN
    BaseRepository.add(user_role)


def test_app_mode_status_update():
    response_sign_in = supabase_client.auth.sign_in_with_password(
        {"email": "beth.bodmas@example.com", "password": "bethbodmas"})

    user = UserRepository.find_by_email('beth.bodmas@example.com')
    supabase_client.table("operational_events").insert({"id": str(uuid.uuid4()),
                                                        "created_by": str(user.id),
                                                        "created_at": datetime.datetime.now().isoformat(),
                                                        "status": OperationalStatus.EMERGENCY.name}).execute()

    supabase_client.table("operational_events").insert({"id": str(uuid.uuid4()),
                                                        "created_by": str(user.id),
                                                        "created_at": datetime.datetime.now().isoformat(),
                                                        "status": OperationalStatus.TEST.name}).execute()

    supabase_client.table("operational_events").insert({"id": str(uuid.uuid4()),
                                                        "created_by": str(user.id),
                                                        "created_at": datetime.datetime.now().isoformat(),
                                                        "status": OperationalStatus.NORMAL.name}).execute()
    supabase_client.auth.sign_out()


def test_unauthorized_app_mode_update():
    try:
        response_sign_in = supabase_client.auth.sign_in_with_password(
            {"email": "adam.abacus@example.com", "password": "adamabacus"})
        user = UserRepository.find_by_email('adam.abacus@example.com')
        supabase_client.table("operational_events").insert({"id": str(uuid.uuid4()),
                                                            "created_by": str(user.id),
                                                            "created_at": datetime.datetime.now().isoformat(),
                                                            "status": OperationalStatus.EMERGENCY.name}).execute()
    except Exception as ex:
        logger.info(ex)
        logger.info("[CORRECT BEHAVIOUR]: User Denied Access for missing AUTHz.")
    finally:
        supabase_client.auth.sign_out()


@db_init_app.command(help="Command to setup resource type and resources")
def setup_utility_resources():
    resource_type_uids = populate_resource_types()
    populate_resources(resource_type_uids=resource_type_uids)
    populate_checklists()


@db_init_app.command(help="Command to setup the database with dummy users, roles, and permissions")
def setup_user_details():
    populate_user_details()
    update_user_permissions_roles_by_cluster()


@db_init_app.command(help="Setup the datebase with points of interest and supporting types")
def setup_points_of_interest():
    populate_point_of_interest_types()
    populate_points_of_interest()


def populate_point_of_interest_types():
    file_path = DATA_DIRECTORY / 'point_types.csv'
    with file_path.open(mode='r', newline='') as file:
        csv_reader = csv.DictReader(file)
        for row in csv_reader:
            point = PointOfInterestType(name=row['name'], geom=row['geom'], point_type=['point_type'])
            BaseRepository.add(point)


def populate_points_of_interest():
    file_path = DATA_DIRECTORY / 'point_of_interests.csv'
    with file_path.open(mode='r', newline='') as file:
        csv_reader = csv.DictReader(file)
        for row in csv_reader:
            point_type = PointOfInterestType(name=row['name'], icon=row['icon'])
            BaseRepository.add(point_type)


@db_init_app.command(help="Sanity check for testing authorization for app mode change")
def test_app_mode_change():
    test_app_mode_status_update()
    test_unauthorized_app_mode_update()


@db_init_app.command(help="Command to setup the database with "
                          "dummy users, roles, permissions, households, clusters, and app mode with sanity check")
def run_all():
    logger.info("Starting to populate db with sample entries...")

    # Sanity check for user sign-up and sign-in flow via supabase
    authenticate_user_signup_signin_signout_via_supabase()

    # Set up a dummy cluster and a household
    populate_cluster_and_household_details()

    # Set up the database with dummy users, roles, and permissions
    setup_user_details()

    # Setup utility resources to be shared during emergency
    setup_utility_resources()

    # Setup points-of-interest and types
    setup_points_of_interest()

    # Sanity check app mode update
    test_app_mode_change()

    # Populate real data
    populate_real_cluster_and_household()
    logger.info("Completed Successfully!")


if __name__ == '__main__':
    db_init_app()
