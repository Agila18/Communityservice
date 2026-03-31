from .auth import router as auth_router
from .screening import router as screening_router
from .cycle import router as cycle_router
from .notebook import router as notebook_router
from .consultation import router as consultation_router
from .reminders import router as reminders_router
from .nutrition import router as nutrition_router
from .vhn import router as vhn_router

__all__ = [
    "auth_router",
    "screening_router",
    "cycle_router",
    "notebook_router",
    "consultation_router",
    "reminders_router",
    "nutrition_router",
    "vhn_router",
]
