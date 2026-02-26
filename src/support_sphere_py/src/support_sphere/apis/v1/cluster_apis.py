import logging
import uuid

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from support_sphere.models.public import UserCaptainCluster
from support_sphere.repositories.public import UserCaptainClusterRepository

router = APIRouter(
    prefix="/clusters",
    tags=["clusters"],
    responses={404: {"description": "Not found"}},
)

logger = logging.getLogger(__name__)


class CaptainGrantRequest(BaseModel):
    user_profile_id: uuid.UUID
    cluster_id: uuid.UUID


class CaptainRevokeRequest(BaseModel):
    user_profile_id: uuid.UUID
    cluster_id: uuid.UUID


@router.post("/{cluster_id}/captains", response_model=dict)
def grant_cluster_captain(cluster_id: uuid.UUID, request: CaptainGrantRequest):
    """
    Grant the cluster captain role to a user for a given cluster.

    Parameters
    ----------
    cluster_id : uuid.UUID
        The ID of the cluster.
    request : CaptainGrantRequest
        The request body containing the user_profile_id to grant the captain role to.

    Returns
    -------
    dict
        A success message with the new UserCaptainCluster entry id.
    """
    if cluster_id != request.cluster_id:
        raise HTTPException(status_code=400, detail="cluster_id in path and body must match")
    try:
        captain_cluster: UserCaptainCluster = UserCaptainClusterRepository.grant_captain(
            user_profile_id=request.user_profile_id,
            cluster_id=request.cluster_id,
        )
    except Exception as ex:
        logger.error(f"Exception Occurred: {ex}")
        raise HTTPException(status_code=502, detail="Some error occurred")
    return {"id": str(captain_cluster.id), "message": "Cluster captain role granted successfully"}


@router.delete("/{cluster_id}/captains", response_model=dict)
def revoke_cluster_captain(cluster_id: uuid.UUID, request: CaptainRevokeRequest):
    """
    Revoke the cluster captain role from a user for a given cluster.

    Parameters
    ----------
    cluster_id : uuid.UUID
        The ID of the cluster.
    request : CaptainRevokeRequest
        The request body containing the user_profile_id to revoke the captain role from.

    Returns
    -------
    dict
        A success message.
    """
    if cluster_id != request.cluster_id:
        raise HTTPException(status_code=400, detail="cluster_id in path and body must match")
    try:
        success: bool = UserCaptainClusterRepository.revoke_captain(
            user_profile_id=request.user_profile_id,
            cluster_id=request.cluster_id,
        )
    except Exception as ex:
        logger.error(f"Exception Occurred: {ex}")
        raise HTTPException(status_code=502, detail="Some error occurred")
    if not success:
        raise HTTPException(status_code=404, detail="Captain entry not found")
    return {"message": "Cluster captain role revoked successfully"}
