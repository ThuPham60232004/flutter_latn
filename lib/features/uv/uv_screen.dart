import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'uv_service.dart';

class UVScreen extends StatefulWidget {
  const UVScreen({Key? key}) : super(key: key);

  @override
  State<UVScreen> createState() => _UVScreenState();
}

class _UVScreenState extends State<UVScreen> with TickerProviderStateMixin {
  double uvIndex = 0.0;
  String uvLevel = 'Đang tải...';
  String uvMessage = 'Đang tải dữ liệu UV...';
  String location = 'Đang lấy vị trí...';
  String locationAddress = '';
  Color uvColor = Colors.grey;

  bool isLoading = true;
  bool hasLocationPermission = false;
  Position? currentPosition;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    _loadUVData();
  }

  Future<void> _loadUVData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Get current location
      Position? position = await UVService.getCurrentLocation();

      if (position != null) {
        setState(() {
          currentPosition = position;
          hasLocationPermission = true;
          location =
              'Vị trí hiện tại (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
        });

        // Get address from coordinates
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );

          if (placemarks.isNotEmpty) {
            Placemark place = placemarks[0];
            String address = '';
            if (place.locality != null && place.locality!.isNotEmpty) {
              address += place.locality!;
            }
            if (place.administrativeArea != null &&
                place.administrativeArea!.isNotEmpty) {
              if (address.isNotEmpty) address += ', ';
              address += place.administrativeArea!;
            }
            if (place.country != null && place.country!.isNotEmpty) {
              if (address.isNotEmpty) address += ', ';
              address += place.country!;
            }

            setState(() {
              locationAddress =
                  address.isNotEmpty ? address : 'Không thể xác định địa chỉ';
            });
          }
        } catch (e) {
          print('Error getting address: $e');
          setState(() {
            locationAddress = 'Không thể xác định địa chỉ';
          });
        }

        // Get UV index from API
        final uvData = await UVService.getUVIndex(
          position.latitude,
          position.longitude,
        );

        if (uvData != null) {
          setState(() {
            uvIndex = (uvData['uv_value'] ?? 0.0).toDouble();
            uvLevel = uvData['level_uv'] ?? UVService.getUVLevel(uvIndex);
            uvMessage = uvData['message'] ?? UVService.getUVMessage(uvIndex);
            uvColor = UVService.getUVColor(uvIndex);
            isLoading = false;
          });
        } else {
          setState(() {
            uvIndex = 0.0;
            uvLevel = 'Không có dữ liệu';
            uvMessage = 'Không thể tải dữ liệu UV từ máy chủ';
            uvColor = Colors.grey;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          hasLocationPermission = false;
          location = 'Không thể lấy vị trí';
          locationAddress = '';
          uvIndex = 0.0;
          uvLevel = 'Cần quyền vị trí';
          uvMessage = 'Vui lòng cấp quyền truy cập vị trí để xem chỉ số UV';
          uvColor = Colors.grey;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        location = 'Lỗi khi tải dữ liệu';
        locationAddress = '';
        uvIndex = 0.0;
        uvLevel = 'Lỗi';
        uvMessage = 'Đã xảy ra lỗi khi tải dữ liệu UV';
        uvColor = Colors.grey;
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadUVData();
  }

  Future<void> _refreshLocation() async {
    setState(() {
      isLoading = true;
      locationAddress = '';
    });

    try {
      Position? position = await UVService.getCurrentLocation();

      if (position != null) {
        setState(() {
          currentPosition = position;
          hasLocationPermission = true;
          location =
              'Vị trí hiện tại (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
        });

        // Get address from coordinates
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );

          if (placemarks.isNotEmpty) {
            Placemark place = placemarks[0];
            String address = '';
            if (place.locality != null && place.locality!.isNotEmpty) {
              address += place.locality!;
            }
            if (place.administrativeArea != null &&
                place.administrativeArea!.isNotEmpty) {
              if (address.isNotEmpty) address += ', ';
              address += place.administrativeArea!;
            }
            if (place.country != null && place.country!.isNotEmpty) {
              if (address.isNotEmpty) address += ', ';
              address += place.country!;
            }

            setState(() {
              locationAddress =
                  address.isNotEmpty ? address : 'Không thể xác định địa chỉ';
              isLoading = false;
            });
          }
        } catch (e) {
          print('Error getting address: $e');
          setState(() {
            locationAddress = 'Không thể xác định địa chỉ';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          hasLocationPermission = false;
          location = 'Không thể lấy vị trí';
          locationAddress = '';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        location = 'Lỗi khi tải dữ liệu';
        locationAddress = '';
        isLoading = false;
      });
    }
  }

  Future<void> _showLocationPermissionDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue),
              const SizedBox(width: 8),
              const Text('Quyền truy cập vị trí'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ứng dụng cần quyền truy cập vị trí để:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• Hiển thị chỉ số UV chính xác cho vị trí hiện tại'),
              const Text('• Cung cấp thông tin địa chỉ chi tiết'),
              const Text('• Đưa ra khuyến nghị bảo vệ phù hợp'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '💡 Vị trí của bạn chỉ được sử dụng để tính toán chỉ số UV và không được lưu trữ.',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _loadUVData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cấp quyền'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cảnh báo UV',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isLoading ? Icons.hourglass_empty : Icons.refresh,
              color: Colors.black,
            ),
            onPressed: isLoading ? null : _refreshData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      uvColor.withOpacity(0.1),
                      uvColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: uvColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Chỉ số UV hiện tại',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                uvLevel,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: uvColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                locationAddress.isNotEmpty
                                    ? locationAddress
                                    : location,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              if (locationAddress.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  location,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                    fontStyle: FontStyle.italic,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    hasLocationPermission
                                        ? Icons.location_on
                                        : Icons.location_off,
                                    size: 14,
                                    color:
                                        hasLocationPermission
                                            ? Colors.green
                                            : Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      hasLocationPermission
                                          ? 'Vị trí tự động'
                                          : 'Cần quyền vị trí',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            hasLocationPermission
                                                ? Colors.green
                                                : Colors.red,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (!hasLocationPermission) ...[
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: _showLocationPermissionDialog,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    minimumSize: Size.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Cấp quyền vị trí',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),
                              ],
                              if (hasLocationPermission) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: _refreshLocation,
                                      icon: Icon(
                                        Icons.my_location,
                                        size: 16,
                                        color: Colors.blue,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      tooltip: 'Làm mới vị trí',
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'Làm mới vị trí',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.blue,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: uvColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: uvColor.withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child:
                                      isLoading
                                          ? CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                            strokeWidth: 3,
                                          )
                                          : Text(
                                            uvIndex.toStringAsFixed(1),
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 18,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF43EA5F),
                                  Color(0xFFFFFF00),
                                  Color(0xFFFFA500),
                                  Color(0xFFFF0000),
                                  Color(0xFF8B00FF),
                                ],
                                stops: [0.0, 0.3, 0.55, 0.8, 1.0],
                              ),
                            ),
                          ),
                          Positioned(
                            left:
                                ((uvIndex.clamp(0, 11) / 11.0) *
                                    (MediaQuery.of(context).size.width - 64)),
                            child: Column(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: uvColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: uvColor.withOpacity(0.3),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 2),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Thấp',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const Text(
                          'Cao',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Cập nhật: ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: uvColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: uvColor.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: uvColor, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cảnh báo UV cao!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: uvColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            uvMessage,
                            style: TextStyle(fontSize: 14, color: uvColor),
                            overflow: TextOverflow.visible,
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildProtectionTips(),
              const SizedBox(height: 24),
              _buildHourlyForecast(),
              const SizedBox(height: 24),
              _buildSafetyGuidelines(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProtectionTips() {
    final List<Map<String, dynamic>> tips = [
      {
        'title': 'Kem chống nắng',
        'description':
            'Sử dụng kem chống nắng SPF 30+ và thoa lại sau mỗi 2 giờ',
        'icon': Icons.wb_sunny,
        'color': Colors.orange,
      },
      {
        'title': 'Quần áo bảo vệ',
        'description': 'Mặc quần áo dài tay, đội mũ rộng vành, đeo kính râm',
        'icon': Icons.accessibility_new,
        'color': Colors.blue,
      },
      {
        'title': 'Tránh nắng giữa trưa',
        'description': 'Hạn chế ra ngoài từ 10h sáng đến 4h chiều',
        'icon': Icons.wb_sunny,
        'color': Colors.red,
      },
      {
        'title': 'Tìm bóng râm',
        'description': 'Tìm nơi có bóng râm khi UV index cao',
        'icon': Icons.beach_access,
        'color': Colors.green,
      },
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Biện pháp bảo vệ',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...tips.map(
          (tip) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tip['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(tip['icon'], color: tip['color'], size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        tip['description'],
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyForecast() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dự báo UV theo giờ',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Icon(Icons.info_outline, color: Colors.grey[600], size: 32),
              const SizedBox(height: 8),
              const Text(
                'Tính năng dự báo theo giờ sẽ được cập nhật sớm',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyGuidelines() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[600], size: 24),
              const SizedBox(width: 12),
              Text(
                'Hướng dẫn an toàn',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildGuidelineItem('UV 0-2: An toàn', 'Có thể ra ngoài bình thường'),
          _buildGuidelineItem(
            'UV 3-5: Trung bình',
            'Cần bảo vệ da, tìm bóng râm',
          ),
          _buildGuidelineItem(
            'UV 6-7: Cao',
            'Giảm thời gian ngoài trời giữa trưa',
          ),
          _buildGuidelineItem(
            'UV 8-10: Rất cao',
            'Tránh ra ngoài, bảo vệ tối đa',
          ),
          _buildGuidelineItem('UV 11+: Cực cao', 'Nguy hiểm, tránh ra ngoài'),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
