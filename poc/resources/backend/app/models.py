from __future__ import annotations
from typing import List
from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, Float, Table
from sqlalchemy.orm import relationship, Mapped

from .database import Base


flight_to_payload_table = Table(
    "flight_to_payload",
    Base.metadata,
    Column("left_id", ForeignKey("flights.id")),
    Column("right_id", ForeignKey("payloads.id")),
)


class Flight(Base):
    __tablename__ = "flights"

    id = Column(Integer, primary_key=True)
    destination = Column(String)
    capacity = Column(Float, default=100)
    ETD = Column(String)
    loads: Mapped[List[Payload]] = relationship(secondary=flight_to_payload_table)
    #loads: list[Payload] = []


class Payload(Base):
    __tablename__ = "payloads"

    id = Column(Integer, primary_key=True)
    name = Column(String)
    description = Column(String)
    weight = Column(Float, default=100)
    loads: Mapped[List[Flight]] = relationship(secondary=flight_to_payload_table)


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    is_active = Column(Boolean, default=True)

    items = relationship("Item", back_populates="owner")


class Item(Base):
    __tablename__ = "items"

    id = Column(Integer, primary_key=True)
    title = Column(String, index=True)
    description = Column(String, index=True)
    owner_id = Column(Integer, ForeignKey("users.id"))

    owner = relationship("User", back_populates="items")
