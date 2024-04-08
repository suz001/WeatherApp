import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import 'package:weather_app/weatherAPI.dart';
import 'package:intl/intl.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);

  Weather? _weather; //store the data we get from API

  //Turn the first character of each word into uppercase
  //Used in current weather information
  String capitalizeFirstLetterOfEachWord(String text) {
    // Split the text into words
    List<String> words = text.split(' ');

    // Capitalize the first letter of each word
    List<String> capitalizedWords = words.map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      } else {
        return '';
      }
    }).toList();

    // Join the capitalized words back into a single string
    return capitalizedWords.join(' ');
  }

TextStyle getCommonTextStyle() {
  return const TextStyle(
    color: Colors.white,
    fontSize:17,
    shadows: [
      Shadow(
        offset: Offset(2.0, 2.0),
        blurRadius: 3.0,
        color: Color.fromARGB(107, 158, 158, 158),
      ),
    ],
  );
}

TextStyle getLargeTextStyle() {
  return getCommonTextStyle().copyWith(fontSize: 70);
}

TextStyle getMediumTextStyle()
{
  return getCommonTextStyle().copyWith(fontSize: 20);
}
  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    try {
      final weather = await _wf.currentWeatherByCityName("New York");
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      //Debug log
      print('Failed to fetch weather data: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: _buildUI(),
      );

  Widget _buildUI() {
    if (_weather == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Container(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(71, 184, 225, 1),
            Color.fromRGBO(74, 145, 225, 1)
          ],
          // Add more colors if you want to create a more complex gradient
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: _locationHeader(),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: _weatherIcon(),
            ),
          ),
          Expanded(
            flex: 5,
            child: Center(
              child: _extraInfo(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationHeader() {
    String dropdownValue = _weather?.areaName ?? "--";
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Image.asset('assets/map.png'),
            ),
            DropdownButton<String>(
              items: <String>['New York'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              dropdownColor: Colors.blue,
              underline: Container(),
              value: dropdownValue,
              icon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Image.asset('assets/opt.png'),
              ),
              style: getCommonTextStyle(),
              onChanged: (String? value) {
                setState(() {
                  dropdownValue = value!;
                });
              },
            ),
          ],
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: IconButton(
            icon: Image.asset('assets/notification.png'),
            onPressed: () {},
          ),
        )
      ],
    );
  }

  Widget _weatherIcon() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.sizeOf(context).height * 0.25,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  "http://openweathermap.org/img/wn/${_weather?.weatherIcon}@4x.png"),
            ),
          ),
        ),
      ],
    );
  }

  Widget _extraInfo() {
    DateTime now = _weather!.date!;
    String windSpeedInKilometerPerHour = (_weather?.windSpeed != null)
        ? ((_weather!.windSpeed! * 3.6).toStringAsFixed(0))
        : 'N/A';
    return Container(
        height: MediaQuery.sizeOf(context).height * 0.4,
        width: MediaQuery.sizeOf(context).width * 0.80,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 255, 255, 0.3),
          borderRadius: BorderRadius.circular(
            13.98,
          ),
          border: Border.all(
            color: const Color.fromRGBO(255, 255, 255, 0.7),
          ),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Today,  ${DateFormat("d MMMM").format(now)}",
                        style: getMediumTextStyle(),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "${_weather?.temperature?.celsius?.toStringAsFixed(0)}°",
                          style: getLargeTextStyle(),
                        ),
                      )
                    ]),
              ),
              Expanded(
                flex: 3,
                child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          capitalizeFirstLetterOfEachWord(
                              _weather?.weatherDescription ?? ""),
                          style: getMediumTextStyle(),
                        ),
                      ),
                    ]), //Weather Description
              ),
              Expanded(
                flex: 2,
                child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(child: Text("")),
                      Expanded(child: Image.asset('assets/windy.png')),
                      Expanded(
                        child: Center(
                            child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text("Wind",
                              style: getCommonTextStyle()),
                        )),
                      ),
                      Expanded(
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text("|",
                                style: getCommonTextStyle()),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          "$windSpeedInKilometerPerHour km/h",
                          style: getCommonTextStyle(),
                        ),
                      ),
                    ]),
              ),
              Expanded(
                flex: 2,
                child:
                    //Hum
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                      const Expanded(child: Text("")),
                      Expanded(
                        child: Center(child: Image.asset('assets/hum.png')),
                      ),
                      Expanded(
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text("Hum",
                                style:getCommonTextStyle()),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text("|",
                                style: getCommonTextStyle(), 
                                )),
                          ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          "${_weather?.windSpeed?.toStringAsFixed(0)} %",
                          style: getCommonTextStyle(),
                        ),
                      ),
                    ]),
              ),
            ]));
  }
}
