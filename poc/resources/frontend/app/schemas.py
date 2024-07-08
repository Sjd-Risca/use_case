from pydantic import BaseModel, RootModel
from typing import List

from poc import schemas as pocschemas


class FlightList(RootModel):
    root: List[pocschemas.Flight]

    def __iter__(self):
        return iter(self.root)

    def __getitem__(self, item):
        return self.root[item]
