# create-user.py
#
# This python script create a new user in supabase.

import argparse
import json
import os
import sys
import pprint
import uuid

from supabase import create_client, Client

# outline:
# - generate password - or ask?
# - store/write password
# - create user - ask for email?
# - add highest admin role

# CLI options:
# - email
# - password
# - supabase auth creds
# --admin (bool) - make an admin


def get_supabase(config) -> Client:
  url: str = config.get("supabaseUrl")
  key: str = config.get("secret_key")
  # TODO check and fail fast
  return create_client(url, key)

def is_true(value:str)->bool:
  return value.lower() in ['true', '1', 't', 'y', 'yes']

def create_user(config):
  supabase_client = get_supabase(config)
  email = config["email"]
  password = config["password"]

  # TODO check if user already exists, get id

  # note: old code uses auth.sign_up, not create_user
  response = supabase_client.auth.admin.create_user(
    {
        "email": email,
        "password": password,
        "email_confirm": True,
    }
  )
  # check None/error response
  if response and response.user:
    user = response.user
    user_id = user.id

    # create profile
    response = supabase_client.table("user_profiles").insert({
      "id": user_id,
    }).execute()

    # create role
    response = supabase_client.table("user_roles").insert({
      "id": str(uuid.uuid4()),
      "user_profile_id": user_id,
      "role": "com_admin", # TODO: from flag: user, subcom_agent, com_admin, admin
    }).execute()

    # create people entry
    people_id = str(uuid.uuid4())
    response = supabase_client.table("people").insert({
      "id": people_id,
      "user_profile_id": user_id,
      "given_name": config.get("given_name"),
      "family_name": config.get("family_name"),
      "nickname": config.get("nickname"),
      "is_safe": is_true(config.get("is_safe")),
      "needs_help": is_true(config.get("needs_help")),
    }).execute()

    person = supabase_client.table("people").select().eq("id", people_id).maybe_single().execute()
    return person
  else:
    print("Empty response")


def main() -> int:
  # parse args
  parser = argparse.ArgumentParser()
  parser.add_argument("-f", "--neighborhood_file", default="neighborhood.json", help="Neighborhood metatdata JSON file.")
  #parser.add_argument("-o", "--output", default=None, help="Write output to a specific file")
  #parser.add_argument("--dart", action="store_true", help="Generate Dart output")
  args = parser.parse_args()

  with open(args.neighborhood_file) as f:
    config = json.load(f)
    user = create_user(config)

    print("Created user:", config['email'], user.data['given_name'], user.data['family_name'])

    return 0

  return 1 # shouldn't get here


if __name__ == '__main__':
    sys.exit(main())