// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Upload{
    struct Access{
        address user;
        bool access; // indicating whether the user has access or not.
    }

    mapping (address => string[]) value; // to store the generated URL by an address of an account, in an array. This line declares a state variable called "value". It's a mapping where the keys are Ethereum addresses and the values are arrays of strings. It's used to store generated URLs associated with each user's address.
    mapping (address => mapping (address => bool)) ownership; // used to give the ownership from one address to another address willingly. This line declares a mapping named "ownership". It's a nested mapping where the keys of the outer mapping are Ethereum addresses (account A), and the keys of the inner mapping are also Ethereum addresses (account B). The values of the inner mapping are booleans. This mapping is used to establish ownership relationships between accounts. If ownership[A][B] is true, it means account A has granted ownership to account B.
    mapping (address => Access[]) accessList; // to give ownership. This line declares a mapping called "accessList". The keys of this mapping are Ethereum addresses, and the values are arrays of "Access" structs. It's used to manage the access control list for ownership transfer. It stores the users who have been granted access to transfer ownership from the key address.
    mapping (address => mapping (address => bool)) previousData; // This line declares another nested mapping called "previousData". It's similar to the "ownership" mapping. It's used to track whether an account (B) has been granted access to transfer ownership from another account (A) before.

    function add(address _user, string calldata url) external { // This function allows external callers to add a URL to the "value" mapping associated with a specific user's address. The function takes two parameters: "_user" which is the user's Ethereum address, and "url" which is the URL to be added.
        value[_user].push(url);
    }

    function allow(address user) external { // This function is used to grant ownership or access rights. It takes a single parameter, "user", which is the Ethereum address of the user being granted access. It first sets the ownership flag in the "ownership" mapping. If "previousData" indicates that this user has been granted access before, it iterates through the "accessList" array to find the corresponding entry and set the access flag to true. Otherwise, if it's the first time, it adds a new "Access" struct to the "accessList" array and sets "previousData" to true.
        ownership[msg.sender][user] = true;
        if (previousData[msg.sender][user] == true){
            for (uint i = 0; i < accessList[msg.sender].length; i++){
                if (accessList[msg.sender][i].user == user) {
                    accessList[msg.sender][i].access = true; // if the user is present in the accessList array
                }
            }
        } else{
            accessList[msg.sender].push(Access(user, true)); // If user is not present then we'll add him/her to the Acess struct or accessList array.
            previousData[msg.sender][user] = true;
        }
    }

    function disallow(address user) external { // This function is used to revoke ownership or access rights. It takes a single parameter, "user," which is the Ethereum address of the user being revoked access from. It sets the ownership flag in the "ownership" mapping to false and iterates through the "accessList" array to find the corresponding entry and set the access flag to false.
        ownership[msg.sender][user] = false;
        for (uint i = 0; i < accessList[msg.sender].length; i++) {
            if (accessList[msg.sender][i].user == user) {
                accessList[msg.sender][i].access = false;
            }
        }
    }

    function display(address _user) external view returns (string[] memory) {
        require(_user == msg.sender || ownership[_user][msg.sender], "You don't have the access.");
        return value[_user];
    }

    function shareAccess() public view returns(Access[] memory){
        return accessList[msg.sender];
    }

}