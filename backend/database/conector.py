from sqlmodel import  SQLModel , Session ,create_engine
from .models import Todo


postgresql_url = 'postgresql://postgres:password@localhost:5432/todo'

engine = create_engine(
    url=postgresql_url,
    echo=True
)


def create_tables():
    SQLModel.metadata.create_all(engine)

create_tables()    

def get_session():
    with Session(engine) as session:
        yield session