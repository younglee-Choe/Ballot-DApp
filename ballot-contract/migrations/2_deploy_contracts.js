var Ballot = artifacts.require("Ballot");

module.exports = function(deployer) {
    deployer.deploy(Ballot,4);
}
// 가네쉬에 배포 (수수료 발생, Wei 단위)