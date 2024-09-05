from enum import Enum


class AppRoles(Enum):
    MEMBER = ("member", "A regular community member")
    CAPTAIN = ("captain", "A cluster captain of the community")
    MANAGER = ("manager", "A LEAP committee member")
    ADMIN = ("admin", "A University of Washington Team member")

    def __init__(self, role, description):
        self.role = role
        self.description = description
