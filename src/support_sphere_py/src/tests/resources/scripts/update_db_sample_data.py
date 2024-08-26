import csv
from pathlib import Path

from support_sphere.models.public import UserProfile, People
from support_sphere.models.auth import User
from support_sphere.repositories.auth import UserRepository
from support_sphere.repositories.public import UserProfileRepository, PeopleRepository

import logging

logger = logging.getLogger(__name__)


def populate_user_details():
    file_path = Path("./src/support_sphere_py/src/tests/resources/data/sample_data.csv")
    with file_path.open(mode='r', newline='') as file:
        csv_reader = csv.DictReader(file)

        for row in csv_reader:
            user_profile = None
            if bool(eval(row['has_profile'])):

                # Create a user
                user = User(email=row['email'], phone=row['phone'])
                UserRepository.add(user)
                user = UserRepository.find_by_email(row['email'])

                # Create a user profile
                profile = UserProfile(username=row['username'], user=user)
                UserProfileRepository.add(profile)
                user_profile = UserProfileRepository.find_by_username(row['username'])

            # Create People Entry
            person_detail = People(given_name=row['given_name'], family_name=row['family_name'],
                                   is_safe=bool(eval(row['is_safe'])), needs_help=bool(eval(row['needs_help'])),
                                   accessibility_needs=bool(eval(row['accessibility_needs'])),
                                   user_profile=user_profile)

            PeopleRepository.add(person_detail)
    logger.info("Database Populated Successfully")


if __name__ == '__main__':
    populate_user_details()