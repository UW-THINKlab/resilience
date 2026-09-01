import argparse
import sys
import uuid

from supabase import Client

from utils import local_supabase, load_json, prompt_config

# outline:
# - generate password - or ask?
# - store/write password
# - create user - ask for email?
# - add highest admin role


def is_true(value: str) -> bool:
    return value.lower() in ["true", "1", "t", "y", "yes"]


def create_profile(supabase: Client, user_id) -> str:
    # create profile
    supabase.table("user_profiles").insert(
        {
            "id": user_id,
        }
    ).execute()
    return user_id


valid_roles = ["user", "subcom_agent", "com_admin", "admin"]


# returns new role ID
def create_role(supabase: Client, profile_id: str, role: str = "user") -> str:
    role_id = str(uuid.uuid4())
    supabase.table("user_roles").insert(
        {
            "id": role_id,
            "user_profile_id": profile_id,
            "role": role,
        }
    ).execute()
    return role_id


def create_person(
    supabase: Client,
    profile_id: str,
    given_name: str,
    family_name: str,
) -> str:
    people_id = str(uuid.uuid4())
    supabase.table("people").insert(
        {
            "id": people_id,
            "user_profile_id": profile_id,
            "given_name": given_name,
            "family_name": family_name,
            "nickname": "",
            "is_safe": True,
            "needs_help": False,
        }
    ).execute()
    return people_id


def create_user(
    email: str, passwd: str, given_name: str, family_name: str, role: str
) -> str:
    supabase = local_supabase()

    # TODO check if user already exists, get id

    try:
        response = supabase.auth.admin.create_user(
            {
                "email": email,
                "password": passwd,
                "email_confirm": True,
            }
        )
        # check None/error response
        if response and response.user:
            user = response.user
            user_id = user.id

            # create profile
            profile_id = create_profile(supabase, user_id)

            # create role
            create_role(supabase, profile_id, role)

            # create people entry
            create_person(supabase, profile_id, given_name, family_name)

            return profile_id
            # supabase_client.table("people").select().eq("id", people_id).maybe_single().execute()
    except Exception as err:
        print("Problem creating user:", email, err)
        return None


def user_from_dict(user: dict) -> str:
    return create_user(
        user["email"],
        user["password"],
        user["given_name"],
        user["family_name"],
        user.get("role", "user"),
    )


def main() -> int:
    # parse args
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-f",
        "--json_file",
        help="Neighborhood metatdata JSON file.",
    )
    parser.add_argument("--email", help="Admin email")
    parser.add_argument("--passwd", help="Admin password")
    parser.add_argument("--given_name", help="Admin given name")
    parser.add_argument("--family_name", help="Admin family name")
    args = parser.parse_args()

    if args.json_file:
        user = load_json(args.json_file)
    else:
        user = {}

    # overlay args
    if args.email:
        user["email"] = args.email

    if args.passwd:
        user["password"] = args.passwd

    if args.given_name:
        user["given_name"] = args.given_name

    if args.family_name:
        user["family_name"] = args.family_name

    prompts = {
        "given_name": "What is the adminstrator's given name?",
        "family_name": "What is the adminstrator's family name?",
        "email": "What is the adminstrator's email?",
        "password": "What is the adminstrator's initial password?",
    }

    prompt_config(user, prompts)

    user = user_from_dict(user)

    print("Created:", user)

    return 0


if __name__ == "__main__":
    sys.exit(main())
