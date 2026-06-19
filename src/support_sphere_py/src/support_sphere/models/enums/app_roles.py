from enum import Enum


class AppRoles(Enum):
    user = ("user", "Referring to those who live in the community, work in the community, or a business entity or a non-profit like a church etc")
    subcom_agent = ("subcommunity_agent", "Cluster captains of the community")
    com_admin = ("community_admin", "Community steering committee member")
    admin = ("admin", "A University of Washington Team member")

    def __init__(self, role, description):
        self.role = role
        self.description = description
