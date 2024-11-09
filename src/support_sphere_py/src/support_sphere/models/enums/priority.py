from enum import Enum


class Priority(Enum):
    LOW = ("low", "Low Priority")
    MEDIUM = ("medium", "Medium Priority")
    HIGH = ("high", "High Priority")

    def __init__(self, priority, description):
        self.priority = priority
        self.description = description
