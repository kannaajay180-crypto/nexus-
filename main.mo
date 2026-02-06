import Array "mo:core/Array";
import Time "mo:core/Time";
import Map "mo:core/Map";
import Iter "mo:core/Iter";
import Order "mo:core/Order";
import Text "mo:core/Text";
import List "mo:core/List";
import Runtime "mo:core/Runtime";
import Principal "mo:core/Principal";
import MixinAuthorization "authorization/MixinAuthorization";
import AccessControl "authorization/access-control";

actor {
  // Authorization Setup
  let accessControlState = AccessControl.initState();
  include MixinAuthorization(accessControlState);

  // ===== Types =====
  public type UserProfile = {
    name : Text;
    role : Text;
    interests : [Text];
    emergencyContact : ?Text;
  };

  public type Trip = {
    id : Nat;
    creator : Principal;
    destination : Text;
    pickupPoint : Text;
    departureTime : Time.Time;
    availableSeats : Nat;
    notes : Text;
    costPerSeat : Nat;
    vehicleType : Text; // "small car", "sedan", "suv"
    estimatedDistance : Nat; // in km
    createdAt : Time.Time;
  };

  // ===== Storage State =====
  let userProfiles = Map.empty<Principal, UserProfile>();
  let trips = Map.empty<Nat, Trip>();

  var nextTripId = 0;

  // ===== User Profile Management =====
  public query ({ caller }) func getCallerUserProfile() : async ?UserProfile {
    if (not (AccessControl.hasPermission(accessControlState, caller, #user))) {
      Runtime.trap("Unauthorized: Only users can view profiles");
    };
    userProfiles.get(caller);
  };

  public query ({ caller }) func getUserProfile(user : Principal) : async ?UserProfile {
    if (caller != user and not AccessControl.isAdmin(accessControlState, caller)) {
      Runtime.trap("Unauthorized: Can only view your own profile");
    };
    userProfiles.get(user);
  };

  public shared ({ caller }) func saveCallerUserProfile(profile : UserProfile) : async () {
    if (not (AccessControl.hasPermission(accessControlState, caller, #user))) {
      Runtime.trap("Unauthorized: Only users can save profiles");
    };
    userProfiles.add(caller, profile);
  };

  // ===== Travel Sharing Core Functionality =====
  public shared ({ caller }) func createTrip(
    destination : Text,
    pickupPoint : Text,
    departureTime : Time.Time,
    availableSeats : Nat,
    notes : Text,
    costPerSeat : Nat,
    vehicleType : Text,
    estimatedDistance : Nat
  ) : async Nat {
    if (not (AccessControl.hasPermission(accessControlState, caller, #user))) {
      Runtime.trap("Unauthorized: Only users can create trips");
    };

    let trip : Trip = {
      id = nextTripId;
      creator = caller;
      destination;
      pickupPoint;
      departureTime;
      availableSeats;
      notes;
      costPerSeat;
      vehicleType;
      estimatedDistance;
      createdAt = Time.now();
    };

    trips.add(nextTripId, trip);
    nextTripId += 1;
    trip.id;
  };

  public query ({ caller }) func getAllTrips() : async [Trip] {
    // Any authenticated user (including guests) can view trips
    trips.values().toArray();
  };

  public query ({ caller }) func getTripsByDestination(destination : Text) : async [Trip] {
    // Any authenticated user (including guests) can search trips
    let filtered = trips.values().toArray().filter(
      func(trip) { Text.equal(trip.destination, destination) }
    );
    filtered;
  };

  public shared ({ caller }) func joinTrip(tripId : Nat) : async () {
    if (not (AccessControl.hasPermission(accessControlState, caller, #user))) {
      Runtime.trap("Unauthorized: Only users can join trips");
    };

    switch (trips.get(tripId)) {
      case (null) { Runtime.trap("Trip not found") };
      case (?trip) {
        if (trip.availableSeats == 0) {
          Runtime.trap("No available seats");
        };

        let updatedTrip : Trip = {
          trip with availableSeats = trip.availableSeats - 1;
        };
        trips.add(tripId, updatedTrip);
      };
    };
  };

  public shared ({ caller }) func updateTrip(
    tripId : Nat,
    destination : Text,
    pickupPoint : Text,
    departureTime : Time.Time,
    availableSeats : Nat,
    notes : Text,
    costPerSeat : Nat,
    vehicleType : Text,
    estimatedDistance : Nat
  ) : async () {
    if (not (AccessControl.hasPermission(accessControlState, caller, #user))) {
      Runtime.trap("Unauthorized: Only users can update trips");
    };

    switch (trips.get(tripId)) {
      case (null) { Runtime.trap("Trip not found") };
      case (?trip) {
        if (trip.creator != caller and not AccessControl.isAdmin(accessControlState, caller)) {
          Runtime.trap("Unauthorized: Only trip creator or admin can update this trip");
        };

        let updatedTrip : Trip = {
          trip with
          destination;
          pickupPoint;
          departureTime;
          availableSeats;
          notes;
          costPerSeat;
          vehicleType;
          estimatedDistance;
        };
        trips.add(tripId, updatedTrip);
      };
    };
  };

  public shared ({ caller }) func deleteTrip(tripId : Nat) : async () {
    if (not (AccessControl.hasPermission(accessControlState, caller, #user))) {
      Runtime.trap("Unauthorized: Only users can delete trips");
    };

    switch (trips.get(tripId)) {
      case (null) { Runtime.trap("Trip not found") };
      case (?trip) {
        if (trip.creator != caller and not AccessControl.isAdmin(accessControlState, caller)) {
          Runtime.trap("Unauthorized: Only trip creator or admin can delete this trip");
        };
        trips.remove(tripId);
        return ();
      };
    };
  };
};
