import 'package:flutter/material.dart';
import 'package:shopping_app/models/place_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/providers/places.dart';
import 'package:shopping_app/widgets/location_input.dart';

class AddPlaceScreen extends StatefulWidget {
  final PlaceModel? address;
  const AddPlaceScreen({super.key, this.address});
  static const routeName = '/addPlace';

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

Widget buildTextField({
  required String label,
  required TextEditingController controller,
  required IconData icon,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 16),
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      enableSuggestions: true,
    ),
  );
}

Widget buildOptionCard(
  IconData icn,
  String label,
  bool isSelected,
  VoidCallback ontap,
) {
  return Card(
    elevation: isSelected ? 2 : 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadiusGeometry.circular(16),
      side: BorderSide(color: isSelected ? Colors.indigo : Colors.black),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: ontap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icn, color: isSelected ? Colors.indigo : Colors.black),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.indigo : Colors.black,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _areaController;
  late TextEditingController _roomNoController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;
  late TextEditingController _phoneNumberController;
  String? selectedType;
  GeoPoint? _userLocation;

  var isLoading = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _areaController = TextEditingController();
    _roomNoController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _pincodeController = TextEditingController();
    _phoneNumberController = TextEditingController();

    if (widget.address != null) {
      _fullNameController.text = widget.address!.fullName;
      _areaController.text = widget.address!.area;
      _roomNoController.text = widget.address!.roomNo;
      _cityController.text = widget.address!.city;
      _phoneNumberController.text = widget.address!.phoneNumber;
      _stateController.text = widget.address!.state;
      _pincodeController.text = widget.address!.pincode;
      _userLocation = widget.address!.location;
      selectedType = widget.address!.addressType;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _areaController.dispose();
    _roomNoController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _phoneNumberController.dispose();

    super.dispose();
  }

  Future<void> saveAddress() async {
    final scaffold = ScaffoldMessenger.of(context);

    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    if (_userLocation == null) {
      scaffold.showSnackBar(
        const SnackBar(content: Text('Please select a location on the map')),
      );
      return;
    }
    if (selectedType == null) {
      scaffold.showSnackBar(
        const SnackBar(content: Text('Please select an address type')),
      );
      return;
    }
    _formKey.currentState!.save();
    final place = PlaceModel(
      widget.address?.id ?? '',
      _fullNameController.text,
      _areaController.text,
      _roomNoController.text,
      _cityController.text,
      _stateController.text,
      _pincodeController.text,
      _userLocation!,
      selectedType!,
      _phoneNumberController.text,
    );

    final provider = Provider.of<Places>(context, listen: false);
    final navigator = Navigator.of(context);
    setState(() {
      isLoading = true;
    });
    try {
      if (widget.address != null) {
        await provider.updateAddress(place);
      } else {
        await provider.saveAddress(place);
      }
      scaffold.showSnackBar(
        SnackBar(
          content: Text(
            widget.address == null
                ? 'Address saved Successfully'
                : 'Address updated successfully',
          ),
        ),
      );
    } catch (error) {
      scaffold.showSnackBar(
        SnackBar(content: Text('Failed to save Address!!')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Address')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(18),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: LocationInput(
                            initialLocation: widget.address?.location,
                            onSelectLocation: (location) {
                              setState(() {
                                _userLocation = location;
                              });
                            },
                            onAddressResolved: ({
                              required area,
                              required city,
                              required pincode,
                              required state,
                            }) {
                              _areaController.text = area;
                              _cityController.text = city;
                              _stateController.text = state;
                              _pincodeController.text = pincode;
                            },
                          ),
                        ),
                      ),

                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(18),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.article_outlined,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Address Details',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),

                                buildTextField(
                                  label: 'Full Name',
                                  controller: _fullNameController,
                                  icon: Icons.person_outline,
                                ),
                                buildTextField(
                                  label: 'Contact Number',
                                  controller: _phoneNumberController,
                                  icon: Icons.call_outlined,
                                ),
                                buildTextField(
                                  label: 'House/Flat/Room No.',
                                  controller: _roomNoController,
                                  icon: Icons.home_outlined,
                                ),
                                buildTextField(
                                  label: 'Area/Street',
                                  controller: _areaController,
                                  icon: Icons.add_road_outlined,
                                ),
                                buildTextField(
                                  label: 'City',
                                  controller: _cityController,
                                  icon: Icons.location_city_outlined,
                                ),
                                buildTextField(
                                  label: 'State',
                                  controller: _stateController,
                                  icon: Icons.map_outlined,
                                ),
                                buildTextField(
                                  label: 'Pincode',
                                  controller: _pincodeController,
                                  icon: Icons.pin_drop_outlined,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    children: [
                                      Icon(Icons.label_outline_sharp, size: 25),
                                      SizedBox(width: 8),
                                      Text(
                                        'Address Type',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    buildOptionCard(
                                      Icons.home_outlined,
                                      'Home',
                                      selectedType == 'Home',
                                      () {
                                        setState(() {
                                          selectedType = 'Home';
                                        });
                                      },
                                    ),
                                    buildOptionCard(
                                      Icons.work_outline_outlined,
                                      'Office',
                                      selectedType == 'Office',
                                      () {
                                        setState(() {
                                          selectedType = 'Office';
                                        });
                                      },
                                    ),
                                    buildOptionCard(
                                      Icons.school_outlined,
                                      'Hostel',
                                      selectedType == 'Hostel',
                                      () {
                                        setState(() {
                                          selectedType = 'Hostel';
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: saveAddress,
              icon: const Icon(
                Icons.save_outlined,
                size: 25,
                color: Colors.white,
              ),
              label: const Text(
                'Save Address',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ButtonStyle(
                elevation: WidgetStatePropertyAll(0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: WidgetStatePropertyAll(
                  Theme.of(context).primaryColor,
                ),
                foregroundColor: WidgetStatePropertyAll(Colors.white),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
