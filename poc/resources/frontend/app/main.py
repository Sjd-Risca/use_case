import os
from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

from . import schemas
from .backend import api_get

app = FastAPI()

script_dir = os.path.dirname(__file__)
st_abs_file_path = os.path.join(script_dir, "static/")
app.mount("/static", StaticFiles(directory=st_abs_file_path), name="static")


templates = Jinja2Templates(directory=os.path.join(script_dir, "templates"))


@app.get("/", response_class=HTMLResponse)
async def home(request: Request):
    return templates.TemplateResponse(
        request=request, name="index.html", context={"id": 10}
    )

@app.get("/flight", response_class=HTMLResponse)
async def show_flights(request: Request):
    flights = schemas.FlightList(api_get('flights'))
    return templates.TemplateResponse(
        request=request, name="flight.html", context={"flights": flights}
    )
