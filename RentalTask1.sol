// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

contract RentalContract {
    struct ContractInfo {
        string typeOfProperty;
        uint256 startRentDate;
        uint256 endRentDate;
        bool isRented;
        User tenantAddress;
        string [] issues;
    }

    struct User {
        address userAddress;
        bool isOwner;
    }
    struct Property {
        User owner;
        string propertyAddress;
        ContractInfo contractInfo;
    }

    string[] private propertyAddresses;

    function getOwners() public view returns (User[] memory) {
        User[] memory ownerList = new User[](propertyAddresses.length);

        for (uint256 i = 0; i < propertyAddresses.length; i++) {
            if (properties[propertyAddresses[i]].owner.isOwner)
                ownerList[i] = properties[propertyAddresses[i]].owner;
        }
        return ownerList;
    }

    function addUser(address _address, bool _isOwner) public pure {
        User memory user;
        user.isOwner = _isOwner;
        user.userAddress = _address;
    }


    mapping(string => Property) public properties;
    

    modifier onlyOwner(address _ownerAddress) {
        require(msg.sender == _ownerAddress, "Only Owner can do this");
        _;
    }

    modifier onlyTenant(string memory _propertyAddress) {
    require(properties[_propertyAddress].contractInfo.tenantAddress.userAddress == msg.sender, "Only tenant can perform this action");
    _;
}


    function addProperty(
        string memory _propertyAddress,
        string memory _typeOfProperty,
        address _ownerAddress
    ) public onlyOwner(_ownerAddress) returns (string memory) {
        bool propertyExists = false;
        //require(propertyOwners[_ownerAddress] == address(0), "Property already exists");
        //require(propertyOwners[_propertyAddress]==users[_ownerAddress], "Property already exists");
        for (uint256 i = 0; i < propertyAddresses.length; i++) {
            if (
                keccak256(abi.encodePacked(propertyAddresses[i])) ==
                keccak256(abi.encodePacked(_propertyAddress))
            ) {
                propertyExists = true;
                break;
            }
        }
        if (propertyExists) return "Property already exist";
        else {
            propertyAddresses.push(_propertyAddress);
            properties[_propertyAddress] = Property({
                propertyAddress: _propertyAddress,
                contractInfo: ContractInfo({
                    typeOfProperty: _typeOfProperty,
                    startRentDate: 0,
                    endRentDate: 0,
                    isRented: false,
                    tenantAddress: User(address(0), false),
                    issues:new string[](0)
                }),
                
                owner: User({userAddress: _ownerAddress, isOwner: true})
            });
            return "Property added succesfully";
        }
    }

    function rentProperty(
        string memory _propertyAddress,
        address _tenantAddress,
        address _ownerAddress,
        uint256 _startRentDate,
        uint256 _endRentDate
    ) public onlyOwner(_ownerAddress) returns (string memory) {
        Property storage property = properties[_propertyAddress];

        if (property.contractInfo.isRented) {
            return "Property is already rented";
        }
        if (_startRentDate < _endRentDate) return "Invalid Rent Date";

        property.contractInfo.startRentDate = _startRentDate;
        property.contractInfo.endRentDate = _endRentDate;
        property.contractInfo.tenantAddress.userAddress = _tenantAddress;
        property.contractInfo.isRented = true;
        return "Property rented to the tenant successfully";
    }

    function terminateRent(string memory _propertyAddress)
        public
        returns (string memory)
    {
        Property storage property = properties[_propertyAddress];

        require(property.contractInfo.isRented, "Property is not rented");

        require(
            msg.sender == property.contractInfo.tenantAddress.userAddress ||
                msg.sender == property.owner.userAddress,
            "Only tenant or owner can terminate the lease"
        );

        property.contractInfo.isRented = false;
        property.contractInfo.tenantAddress.userAddress = address(0);

        return "Lease terminated successfully";
    }

    function reportIssue(string memory _propertyAddress, string memory _issueDescription) public onlyTenant(_propertyAddress) returns (string memory) {
    Property storage property = properties[_propertyAddress];
    
    require(property.contractInfo.isRented, "Property is not rented");
    
    
    property.contractInfo.issues.push(_issueDescription);
    
    return "Issue reported successfully";
}

}
