"""
User role definitions for the Resilience App.

This module is the canonical location where all user roles are defined.
To add or modify roles, update the :class:`AppRoles` enum below.
"""
from enum import Enum


class AppRoles(Enum):
    USER = ("user", "Referring to those who live in the community, work in the community, or a business entity or a non-profit like a church etc")
    SUBCOM_AGENT = ("subcommunity_agent", "Cluster captains of the community")
    COM_ADMIN = ("community_admin", "Community steering committee member")
    ADMIN = ("admin", "A University of Washington Team member")

    def __init__(self, role, description):
        self.role = role
        self.description = description
