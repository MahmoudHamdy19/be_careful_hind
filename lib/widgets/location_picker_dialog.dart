import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerDialog extends StatefulWidget {
  final LatLng? initialPosition;

  const LocationPickerDialog({super.key, this.initialPosition});

  @override
  _LocationPickerDialogState createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  late GoogleMapController mapController;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        width: double.infinity,
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 0),
            // Map
            Expanded(
              child: GoogleMap(
                onMapCreated: (controller) {
                  setState(() {
                    mapController = controller;
                  });
                },
                initialCameraPosition: CameraPosition(
                  target: widget.initialPosition ?? LatLng(0, 0),
                  zoom: 15,
                ),
                onTap: (LatLng location) {
                  setState(() {
                    _selectedLocation = location;
                  });
                },
                markers: _selectedLocation != null
                    ? {
                  Marker(
                    markerId: MarkerId('selected-location'),
                    position: _selectedLocation!,
                  ),
                }
                    : {},
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
            ),
            // Footer with confirmation button
            Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _selectedLocation != null
                      ? () {
                    Navigator.pop(context, _selectedLocation);
                  }
                      : null,
                  child: Text('Confirm Location'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}