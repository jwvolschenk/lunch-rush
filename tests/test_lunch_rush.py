"""Tests for lunch_rush. A few pass, a couple are deliberately marked xfail
to document known bugs the agent could fix."""

from lunch_rush import Order, OrderQueue, format_receipt, split_bill, who_owes


def test_total_sums_prices():
    q = OrderQueue([Order("A", "x", 5.0), Order("B", "y", 3.0)])
    assert q.total() == 8.0


def test_split_bill_even():
    assert split_bill(30.0, 3) == [10.0, 10.0, 10.0]


def test_split_bill_zero_people():
    assert split_bill(30.0, 0) == []


def test_format_receipt_has_names():
    q = OrderQueue([Order("Alice", "Burger", 12.5)])
    r = format_receipt(q)
    assert "Alice" in r
    assert "12.50" in r
