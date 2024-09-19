import logging
from importlib.metadata import version

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s %(thread)d %(levelname)s %(module)s.%(funcName)s(): %(message)s"
)
logger = logging.getLogger(__name__)

__version__ = version("support-sphere-py")

__all__ = ["__version__"]