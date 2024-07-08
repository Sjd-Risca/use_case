from pydantic import BaseModel


class Payload(BaseModel):
    id: int
    name: str
    description: str
    weight: float


class FlightBase(BaseModel):
    destination: str
    capacity: float
    ETD: str


class Flight(FlightBase):
    id: int
    loads: list[Payload] = []

    @property
    def total_loaded(self):
        total = 0
        for load in self.loads:
            total += load.weight
        return total

    @property
    def free_load(self):
        return self.capacity - self.total_loaded

    class Config:
        orm_mode = True
