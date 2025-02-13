import 'package:equatable/equatable.dart';

import './address_model.dart';

class AddressDetailModel extends Equatable {
  const AddressDetailModel({
    this.result,
    this.status,
  });

  final Result? result;
  final String? status;

  AddressDetailModel copyWith({
    Result? result,
    String? status,
  }) =>
      AddressDetailModel(
        result: result ?? this.result,
        status: status ?? this.status,
      );

  factory AddressDetailModel.fromJson(Map<String, dynamic> json) =>
      AddressDetailModel(
        result: Result.fromMap(json["result"]),
        status: json["status"],
      );

  Map<String, dynamic> toMap() => {
        "result": result!.toMap(),
        "status": status,
      };

  /// Use to send data
  Address mapToAddress(Prediction value) {
    String postcode = '';
    String city = '';
    String state = '';
    String street = '';
    String route = '';
    String suburb = '';
    String country = 'Australia';
    final addressComponents = result?.addressComponents ?? [];
    for (int index = 0; index < addressComponents.length; index++) {
      final element = addressComponents[index];
      final types = element.types ?? [];

      if (types.contains('street_number')) {
        street = element.longName ?? '';
      }

      if (types.contains('route')) {
        route = element.longName ?? '';
      }

      if (types.contains('postal_code')) {
        postcode = element.longName ?? '';
      }

      if (types.contains('country')) {
        country = element.longName ?? '';
      }

      if (types.contains('administrative_area_level_1')) {
        state = element.shortName ?? '';
      }

      if (types.contains('locality')) {
        city = element.shortName ?? '';
      }

      if (types.contains('administrative_area_level_2') && city.isEmpty) {
        city = element.shortName ?? '';
      }

      if (types.contains('sublocality')) {
        suburb = element.shortName ?? '';
      }

      if (types.contains('administrative_area_level_3') && suburb.isEmpty) {
        suburb = element.shortName ?? '';
      }
    }

    return Address(
      address: street.isEmpty && route.isEmpty ? '' : '$street $route',
      country: country,
      postcode: postcode,
      city: city,
      state: state,
      suburb: suburb,
      lat: result?.geometry?.location?.lat ?? 0,
      lng: result?.geometry?.location?.lng ?? 0,
      id: result?.placeId ?? '',
    );
  }

  @override
  List<Object?> get props => [
        result,
        status,
      ];
}

class Result {
  Result({
    this.addressComponents,
    this.businessStatus,
    this.formattedAddress,
    this.formattedPhoneNumber,
    this.geometry,
    this.name,
    this.placeId,
    this.reference,
    this.website,
  });

  final List<AddressComponent>? addressComponents;
  final String? businessStatus;
  final String? formattedAddress;
  final String? formattedPhoneNumber;
  final Geometry? geometry;
  final String? name;
  final String? placeId;
  final String? reference;
  final String? website;

  Result copyWith({
    List<AddressComponent>? addressComponents,
    String? businessStatus,
    String? formattedAddress,
    String? formattedPhoneNumber,
    Geometry? geometry,
    String? name,
    String? placeId,
    String? reference,
    String? website,
  }) =>
      Result(
        addressComponents: addressComponents ?? this.addressComponents,
        businessStatus: businessStatus ?? this.businessStatus,
        formattedAddress: formattedAddress ?? this.formattedAddress,
        formattedPhoneNumber: formattedPhoneNumber ?? this.formattedPhoneNumber,
        geometry: geometry ?? this.geometry,
        name: name ?? this.name,
        placeId: placeId ?? this.placeId,
        reference: reference ?? this.reference,
        website: website ?? this.website,
      );

  factory Result.fromMap(Map<String, dynamic> json) => Result(
        addressComponents: List<AddressComponent>.from(
            (json["address_components"] ?? [])
                .map((x) => AddressComponent.fromMap(x))),
        businessStatus: json["business_status"],
        formattedAddress: json["formatted_address"],
        formattedPhoneNumber: json["formatted_phone_number"],
        geometry: Geometry.fromMap(json["geometry"]),
        name: json["name"],
        placeId: json["place_id"],
        reference: json["reference"],
        website: json["website"],
      );

  Map<String, dynamic> toMap() => {
        "address_components":
            List<dynamic>.from(addressComponents!.map((x) => x.toMap())),
        "business_status": businessStatus,
        "formatted_address": formattedAddress,
        "formatted_phone_number": formattedPhoneNumber,
        "geometry": geometry!.toMap(),
        "name": name,
        "place_id": placeId,
        "reference": reference,
        "website": website,
      };
}

class AddressComponent {
  AddressComponent({
    this.longName,
    this.shortName,
    this.types,
  });

  final String? longName;
  final String? shortName;
  final List<String>? types;

  AddressComponent copyWith({
    String? longName,
    String? shortName,
    List<String>? types,
  }) =>
      AddressComponent(
        longName: longName ?? this.longName,
        shortName: shortName ?? this.shortName,
        types: types ?? this.types,
      );

  factory AddressComponent.fromMap(Map<String, dynamic> json) {
    return AddressComponent(
      longName: json["long_name"],
      shortName: json["short_name"],
      types: List<String>.from((json["types"]).map((x) => x)),
    );
  }

  Map<String, dynamic> toMap() => {
        "long_name": longName,
        "short_name": shortName,
        "types": List<String>.from(types!.map((x) => x)),
      };
}

class Geometry {
  Geometry({
    this.location,
    this.viewport,
  });

  final Location? location;
  final Viewport? viewport;

  Geometry copyWith({
    Location? location,
    Viewport? viewport,
  }) =>
      Geometry(
        location: location ?? this.location,
        viewport: viewport ?? this.viewport,
      );

  factory Geometry.fromMap(Map<String, dynamic> json) => Geometry(
        location: Location.fromMap(json["location"]),
        viewport: Viewport.fromMap(json["viewport"]),
      );

  Map<String, dynamic> toMap() => {
        "location": location!.toMap(),
        "viewport": viewport!.toMap(),
      };
}

class Location {
  Location({
    this.lat,
    this.lng,
  });

  final double? lat;
  final double? lng;

  Location copyWith({
    double? lat,
    double? lng,
  }) =>
      Location(
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
      );

  factory Location.fromMap(Map<String, dynamic> json) => Location(
        lat: json["lat"].toDouble(),
        lng: json["lng"].toDouble(),
      );

  Map<String, dynamic> toMap() => {
        "lat": lat,
        "lng": lng,
      };
}

class Viewport {
  Viewport({
    this.northeast,
    this.southwest,
  });

  final Location? northeast;
  final Location? southwest;

  Viewport copyWith({
    Location? northeast,
    Location? southwest,
  }) =>
      Viewport(
        northeast: northeast ?? this.northeast,
        southwest: southwest ?? this.southwest,
      );

  factory Viewport.fromMap(Map<String, dynamic> json) => Viewport(
        northeast: Location.fromMap(json["northeast"]),
        southwest: Location.fromMap(json["southwest"]),
      );

  Map<String, dynamic> toMap() => {
        "northeast": northeast!.toMap(),
        "southwest": southwest!.toMap(),
      };
}

class Address {
  Address({
    this.id,
    required this.address,
    required this.city,
    required this.state,
    this.suburb,
    required this.country,
    required this.postcode,
    required this.lat,
    required this.lng,
  });

  String? id;
  String address;
  String city;
  String state;
  String country;
  String postcode;
  String? suburb;
  double lat;
  double lng;

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json["id"] ?? "",
        address: json["address"] ?? "",
        city: json["city"] ?? "",
        state: json["state"] ?? "",
        country: json["country"] ?? "",
        postcode: json["postcode"] ?? "",
        lat: json["lat"] ?? 0,
        lng: json["lng"] ?? 0,
        suburb: json['suburb'] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "address": address,
        "city": city,
        "state": state,
        "country": country,
        "postcode": postcode,
        "lat": lat,
        "lng": lng,
        "suburb": suburb,
      };
}
