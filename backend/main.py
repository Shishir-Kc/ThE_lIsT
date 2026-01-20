from fastapi import FastAPI , Depends ,HTTPException
from typing import Annotated
from database.models import (get_Todo,Todo,
                             updated_Todo,
                             update_priority,
                             delete_todo,
                             visulze_activity
                             )
from database.conector import get_session
from sqlmodel import Session,select

Session_Dp =Annotated[Session,Depends(get_session)] 


app = FastAPI()



@app.get("/")
def home():
    return {
        'hello':"hello"
    }


@app.post("/api/v1/add/todo/",response_model=Todo)
def add_todo(task:get_Todo,session:Session_Dp):
    db_todo = Todo(
        task_name=task.task_name,
        task_description=task.task_description,
        start_date=task.start_date,
        end_date=task.end_date,
        priority_level=task.priority_level
    )
    session.add(db_todo)
    session.commit()
    session.refresh(db_todo)

    return db_todo

@app.get("/api/v1/get/todo/",response_model=list[Todo])
def get_todo(session:Session_Dp):
    querry = session.exec(select(Todo)).all()
    return querry


@app.post("/api/v1/update/todo/",response_model=updated_Todo)
def updated_todo(task:updated_Todo,session:Session_Dp):

    try:
        query = session.exec(select(Todo).where(Todo.id ==task.id)).first()
        if query.completed == False:
            query.completed = True
            query.ended_at = task.ended_at     
        else:
            query.completed = False
            query.ended_at = None

        session.add(query)
        session.commit()
        session.refresh(query)    

    except Exception as e:
        print(e)
        return HTTPException(status_code=404,detail='task not found ! ')

    return query

@app.put("/api/v1/todo/update/priority/",response_model=Todo)
def update_priority(task:update_priority,session:Session_Dp):
    try:
        query = session.exec(select(Todo).where(Todo.id==task.id)).first()
        query.priority_level = task.priority_level
        session.add(query)
        session.commit()
        session.refresh(query)

    except :
        return HTTPException(status_code=404,detail="task is not available ! ")

    return query

@app.post("/api/v1/delete/todo/")
def update_priority(task:delete_todo,session:Session_Dp):
    try:
        query = session.exec(select(Todo).where(Todo.id==task.id)).first()
        session.delete(query)
        session.commit()
    except :
        return HTTPException(status_code=404,detail="task is not available ! ")

    return {
        'status':"sucessful"
    }


@app.get("/api/v1/activity/",response_model=list[visulze_activity])
def get_activity(session:Session_Dp):
    try:
        querry = session.exec(select(Todo).filter(Todo.completed==True))



    except:
        return HTTPException(status_code=404,detail="no task has been completed ! ")    



    return querry