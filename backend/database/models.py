from sqlmodel import Field , SQLModel 
import uuid
from typing import Optional
from datetime import datetime




class Todo(SQLModel,table=True):
    id:uuid.UUID = Field(index=True,default_factory=uuid.uuid4,primary_key=True)
    task_name:str = Field(index=True)
    task_description:str |None = Field(default=None)
    start_date:datetime = Field(default_factory=datetime.utcnow)
    end_date:Optional[datetime] |None = Field(default=None)
    ended_at:Optional[datetime] = Field(default=None)
    completed : Optional[bool] = Field(default=False)
    priority_level :int

class get_Todo(SQLModel):
    task_name:str = Field(index=True)
    task_description:str |None = Field(default=None)
    start_date:datetime = Field(default_factory=datetime.utcnow)
    end_date:Optional[datetime] |None = Field(default=None)
    priority_level :int

class updated_Todo(SQLModel):
    id:uuid.UUID
    ended_at:Optional[datetime] = Field(default=None)
    completed : Optional[bool] = Field(default=False)

class update_priority(SQLModel):
    id:uuid.UUID
    priority_level :int

class delete_todo(SQLModel):
    id:uuid.UUID


class visulze_activity(SQLModel):
    start_date:datetime = Field(default_factory=datetime.utcnow)
    ended_at:Optional[datetime] = Field(default=None)
    completed : Optional[bool] = Field(default=False)