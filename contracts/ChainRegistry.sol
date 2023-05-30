// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/**
 * @title  ChainRegistry
 * @notice ChainRegistry acts as a way to register and query
 *         contract addresses for an OP Stack chain
 */
contract ChainRegistry {

    /**
     * @notice Only the deployment admin can claim a deployment
     */
    modifier onlyAdmin(string memory _deployment) {
        require(deploymentAdmins[_deployment][msg.sender], 
                "Only the deployment admin can claim a deployment");
        _;
    }

    /**
    * @notice Only unclaimed deployment names can be added
    */
    modifier deploymentUnclaimed(string memory _deployment) {
        require(deploymentExists[_deployment] == false, 
                "Only unclaimed deployment names can be added");
        _;
    }

    /**
    * @notice Only unclaimed deployment names can be added
    */
    modifier deploymentClaimed(string memory _deployment) {
        require(deploymentExists[_deployment], 
                "Only unclaimed deployment names can be added");
        _;
    }

    /**
     * @notice Emitted any time a deployment is claimed
     *
     * @param deployment The name of the deployment claimed
     * @param admin The admin of the deployment claimed
     */
    event DeploymentClaimed(string deployment, address admin);

    /**
     * @notice Emitted any time the admin transfers ownership of a
     *         deployment to a new admin address
     *
     * @param oldAdmin The former admin who made the change
     * @param newAdmin The new admin
     */
    event AdminChanged(address oldAdmin, address newAdmin);

    /**
     * @notice Struct representing a deployment entry with
     *         a contract's name and associated address
     */
    struct DeploymentEntry {
        string entryName;
        address entryAddress;
    }

    /**
     * @notice Mapping of deployment names to their existence
     */
    mapping(string => bool) deploymentExists;

    /**
     * @notice Mapping of deployment names to deploymentAdmins
     */
    mapping(string => mapping(address => bool)) deploymentAdmins;

    /**
     * @notice Mapping of deployment names names & contract addr's
     */
    mapping(string => mapping(string => address)) registry;

    /**
     * @notice Claims a deployment
     *
     * @param _deployment The deployment to claim
     */
    function claimDeployment(string calldata _deployment, address _admin) public deploymentUnclaimed(_deployment) {
        // Set the deploymentAdmin address of this mapping to true
        deploymentAdmins[_deployment][_admin] = true;

        // Set the deployments existence to true
        deploymentExists[_deployment] = true;

        emit DeploymentClaimed(_deployment, _admin);
    }

    function deploymentAdmin(string calldata _deployment, address _admin) public view returns (bool){
        return deploymentAdmins[_deployment][_admin];
    }

    /**
    * @notice Claims multiple deployments for a single address
    *
    * @param _deployments The list of deployment names to be added to the registry
    * @param _admin The address that will claim these deployments
    */
    function claimDeployments(string[] calldata _deployments, address _admin) public {
        for (uint256 i = 0; i < _deployments.length; i++) {
            claimDeployment(_deployments[i], _admin);
        }
    }

    /**
     * @notice Transfers ownership of a deployment to a new admin
     *
     * @param _deployment The deployment to transfer ownership of
     * @param _newAdmin The new admin to transfer ownership to
     */
    // TODO: Implement allowAdmin(string memory _deployment, address _admin);
    // function transferAdmin(string calldata _deployment, address _newAdmin) public onlyAdmin(_deployment) {
    //     // Set the deploymentAdmin as _newAdmin
    //     registry[_deployment].deploymentAdmin = _newAdmin;

    //     emit AdminChanged(msg.sender, _newAdmin);
    // }

    // TODO: Implement revokeAdmin(string memory _deployment, address _admin);

    /**
     * @notice Registers entries in a deployment
     *
     * @param _deployment The deployment to register entries in
     * @param _entries An array of entries to register
     */
    function register(string calldata _deployment, 
                DeploymentEntry[] calldata _entries) 
                public deploymentClaimed(_deployment) 
                onlyAdmin(_deployment) {
        for (uint i = 0; i < _entries.length; i++) {
            // Sets the Entry Name key to EntryAddress value in registry mapping for
            // a given deployment
            registry[_deployment][_entries[i].entryName] = _entries[i].entryAddress;
        }
    }

    /**
     * @notice Queries the chain registry for a list of deployment addresses
     *
     * @param _deployment The deployment to query
     * @param _names An array of names to query the addresses for
     *
     * @return An array of contract addresses for the names queried
     */
    function query(string calldata _deployment, 
                string[] calldata _names) 
                public view deploymentClaimed(_deployment) 
                returns (address[] memory) {
        address[] memory addresses = new address[](_names.length);
        for (uint i = 0; i < _names.length; i++) {
            addresses[i] = registry[_deployment][_names[i]];
        }
        return addresses;
    }
}