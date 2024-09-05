from enum import Enum


class OperationalStatus(Enum):
    EMERGENCY = ("emergency", "Total Emergency Mode")
    TEST = ("test", "Test Emergency Mode")
    NORMAL = ("normal", "Normal Operation Mode")

    def __init__(self, status, description):
        self.status = status
        self.description = description
