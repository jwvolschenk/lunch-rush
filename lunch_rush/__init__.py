"""Lunch Rush — team lunch order helper.

Core functions for splitting bills, tracking who ordered what, and managing
an order queue. This is a rough first cut.
"""

from __future__ import annotations

from dataclasses import dataclass, field


@dataclass
class Order:
    """One person's lunch order."""

    name: str
    item: str
    price: float


@dataclass
class OrderQueue:
    """A queue of orders for a single lunch run."""

    orders: list[Order] = field(default_factory=list)

    def add(self, order: Order) -> None:
        self.orders.append(order)

    def total(self) -> float:
        return sum(o.price for o in self.orders)


def split_bill(total: float, n_people: int) -> list[float]:
    """Split a bill evenly. Note: has a known rounding bug when total doesn't
    divide cleanly — the last person may pay a cent too few."""
    if n_people == 0:
        return []
    per = total / n_people
    return [per for _ in range(n_people)]


def who_owes(orders: list[Order]) -> dict:
    """Return {name: amount_owed} from a list of orders.

    NOTE: no return type annotation, and silently merges duplicate names
    by overwriting instead of summing — likely a bug.
    """
    result = {}
    for o in orders:
        result[o.name] = o.price  # bug: overwrites instead of summing
    return result


def format_receipt(queue: OrderQueue) -> str:
    """Render a simple text receipt of the order queue."""
    lines = [f"Lunch Rush — {len(queue.orders)} orders"]
    for o in queue.orders:
        lines.append(f"  {o.name}: {o.item} — ${o.price:.2f}")
    lines.append(f"  Total: ${queue.total():.2f}")
    return "\n".join(lines)


def main() -> None:
    q = OrderQueue()
    q.add(Order("Alice", "Burger", 12.50))
    q.add(Order("Bob", "Salad", 9.00))
    q.add(Order("Alice", "Fries", 3.50))
    print(format_receipt(q))
    print("Who owes:", who_owes(q.orders))


if __name__ == "__main__":
    main()
