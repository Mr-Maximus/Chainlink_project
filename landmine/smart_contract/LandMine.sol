
pragma solidity ^0.6.2;
pragma experimental ABIEncoderV2;

import "ERC721.sol";

/* LandMine is a platform where each Property{piece of land, apartment, bungalow} is represented by the nft and these nft' are put up for the 
   sale and then buyer buy these nft

*/

 contract  LandMine is  ERC721("LandMine", "Lmine"){
     
     // Property  Details
     struct Property{
                    string name;
                    string description;
                    bool isActive;      // is property active
                    uint256 price;      // per day price in wei (1 ether = 10^18 wei)
                    address owner;      // Owner of the property
                                      
                                      
     }
     
     // Booking details of specific property
     
     struct Booking {
                    uint256 propertyId;
                    uint256 dateFrom;
                    uint256 dateTo;
                    address user;
                    }
                    
        enum state{ paymentdone, transactioncomplete}
                    
     
         uint public propertyId = 999;
         uint public bookingId = 777;
          
         
        // mapping of propertyId to Property object
        mapping(uint256 => Property) public properties;
        
        // mapping of bookingId to Booking object
         mapping(uint256 => Booking) public bookings;
         
        // mapping of  propertyId to agreement
        mapping(uint256 => string) agreement;
        
        // mapping of propertyId to state for booking
        mapping(uint256 => state) bookingState;
        
        // mapping of propertyId to owner
        mapping(uint256 => address) Cowner;
        
        // event when new Property is listed
        event NewPropertyforsale(uint);
        
        // event when Property get sold
        event Propertysold(address oldOwner, address newOwner, uint pid);
        
        // event when new booking is made
        event NewBooking(uint propertyId, uint bookingId);

  
                       // putting property for sale
                       function rentOutproperty(string memory name, string memory description, uint256 price) public {
                        Property memory property = Property(name, description, true /* isActive */, price, msg.sender /* owner */);
                        
                        // Persist `property` object to the "permanent" storage
                        properties[propertyId] = property;
                        
                         _mint( msg.sender, propertyId);
                         
                        // emit an event to notify the clients
                        emit NewPropertyforsale(propertyId);
                         
                          propertyId++;
                             
                         }
                         
                         // buyer will buy the property
                          function rentProperty(uint256 _propertyId, string memory _agreement,  uint256 fromTime, uint256 toTime) public payable {
                                   
                                   require(msg.value > 0);
                                   
                                    // Retrieve `property` object from the storage
                                    Property memory property = properties[_propertyId];
                                    
                                    
                                    agreement[_propertyId] = _agreement;
                                    
                                    bookingState[_propertyId] = state.paymentdone;
                                    Cowner[_propertyId] = msg.sender;
                             }
                         
                         
                         /// making the property as inactive
                         function markPropertyAsInactive(uint256 _propertyId) public {
                                    require(
                                      properties[_propertyId].owner == msg.sender,
                                      "THIS IS NOT YOUR PROPERTY"
                                    );
                                    properties[_propertyId].isActive = false;
                                    }
                                    
                                    
                        // sending fund  from contract to beneficiary            
                        function _sendFunds (address beneficiary, uint256 value) internal {
                          
                           address(uint160(beneficiary)).transfer(value);
                         }
                         
                         
                         // Create new booking  for the pproperty
                         function _createBooking(uint256 _propertyId, uint256 fromTime, uint256 toTime) internal {
                             
                            // Create a new booking object
                            bookings[bookingId] = Booking(_propertyId, fromTime, toTime, msg.sender);
                            
                            // Retrieve `property` object from the storage
                            Property memory property = properties[_propertyId];
                            
                            // send funds to the owner of the property
                               _sendFunds(property.owner, msg.value);

                            // conditions for a booking are satisfied, so make the booking
                             _createBooking(_propertyId, fromTime, toTime);
                            
                           
                            
                            // Emit an event to notify clients
                            emit NewBooking(_propertyId, bookingId);
                            bookingId++;
                            

                         }
                         
                         
                         // geting agreement details
                         function getAgreement( uint256 pid) public view returns(string memory){
                          
                          
                          return agreement[pid];   
                         }
                         
                         // geting details of Property
                         function getDetails(uint256 pid) public view returns(Property memory){
                             
                             return properties[pid];
                             
                             
                         }
                         
                        // seller complete the transaction after payament is done
                        function completeTransaction( uint256 _propertyId) public {
                            
                             require( bookingState[_propertyId] == state.paymentdone);
                             
                             address buyer = Cowner[_propertyId];
                             
                              _transfer(msg.sender,  buyer, _propertyId);
                              
                              emit Propertysold(msg.sender, buyer, _propertyId);
                             
                             
                            
                        }
                        
                        
                        
                         
                         
                         
                                            
                         
 }   