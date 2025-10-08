from pydantic import BaseModel, Field, validator
from typing import List, Dict, Any, Optional, Tuple

class Shot(BaseModel):
    prompt: str
    seed: int = 123
    cfg: float = 6.0
    steps: int = 30
    size: List[int] = Field(default_factory=lambda: [1024, 1024])

    @validator("size")
    def _size_has_two_ints(cls, v):
        if not isinstance(v, list) or len(v) != 2 or not all(isinstance(x,int) for x in v):
            raise ValueError("size must be [width,height]")
        return v

class ShotPlan(BaseModel):
    task: str = "generic"
    objects: List[str] = Field(default_factory=list)
    style: Dict[str, Any] = Field(default_factory=lambda: {"keywords": []})
    neg: List[str] = Field(default_factory=lambda: ["blurry","text artifacts"])
    shots: List[Shot] = Field(default_factory=list)
    raw: Dict[str, Any] = Field(default_factory=dict)
