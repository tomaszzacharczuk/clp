pragma solidity ^0.4.11;


library DoublyLinkedList {
    struct Elements {
        address head;
        address tail;
        uint256 size;
        mapping(address => Element) elements;
    }

    struct Element {
        address previous;
        address next;
        uint256 data;
    }

    function getElement(Elements storage self, address key) public returns (uint256) {
        return self.elements[key].data;
    }

    function addElement(Elements storage self, address key, uint256 value) public returns (bool success) {
        Element storage elem = self.elements[key];
        if (elem.data != 0) {
            return false;
        }

        if (self.size == 0) {
            self.head = key;
            self.tail = key;
        } else {
            self.elements[self.head].next = key;
            elem.previous = self.head;
            self.head = key;
        }
        elem.data = value;
        self.size++;
        return true;
    }

    function removeElement(Elements storage self, address key) public returns (bool success) {
        Element storage elem = self.elements[key];
        if (self.size == 0 || elem.data == 0) {
            return false;
        } else if (self.size == 1) {
            self.head = 0x0;
            self.tail = 0x0;
        } else if (key == self.head) {
            self.head = elem.previous;
        } else if (key == self.tail) {
            self.tail = elem.next;
        } else {
            self.elements[elem.previous].next = elem.next;
            self.elements[elem.next].previous = elem.previous;
        }
        delete self.elements[key];
        self.size--;
    }
}