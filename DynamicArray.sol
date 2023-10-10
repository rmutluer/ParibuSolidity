// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

contract DynamicArray {
    // function getAllAdmins() public view returns (Account[3] memory){
    //     Account[3] memory _admins;
    //     for(uint i=0; i<3; i++){
    //         _admins[i]=admins[i];
    //     }
    //     return _admins;
    //     //dinamik olarak adminlerin döndürülmesi
    // }

    struct Account {
        string name;
        string surname;
        uint256 balance;
    }

    uint256 private index;

    Account[] public admins;

    function addAdmin(Account memory admin) public {
        require(index < 3, "Has no slot"); 
        admins.push(admin);
        index++;
    }

    function getAllAdmins() public view returns (Account[] memory) {
        Account[] memory dynamicAdmins = new Account[](index);
        for (uint256 i = 0; i < index; i++) {
            dynamicAdmins[i] = admins[i];
        }
        return dynamicAdmins;
    }
}
