import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../fcm.dart';
import '../../common.dart';

const String GDPR_CONSENT_PREFS_KEY = 'gdpr_consent';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

enum _SettingValueMap {
  TYPE,
  VALUE,
}

enum _SettingValueType {
  BOOL,
  //STRING,
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, Map<_SettingValueMap, dynamic>> _settings = {
    GDPR_CONSENT_PREFS_KEY: {
      _SettingValueMap.TYPE: _SettingValueType.BOOL,
      _SettingValueMap.VALUE: false
    },
    'is-surprise': {
      _SettingValueMap.TYPE: _SettingValueType.BOOL,
      _SettingValueMap.VALUE: false
    }
  };
  final Map<String, String> _settingsTitle = {
    GDPR_CONSENT_PREFS_KEY: "Zgoda RODO",
    'is-surprise': '( ͡° ͜ʖ ͡°)'
  };

  SharedPreferences _prefs = null;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _prefs = prefs;
        _settings.forEach(
            (k, v) =>
          v[_SettingValueMap.VALUE] = _prefs.get(k) ?? v[_SettingValueMap.VALUE]
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var settingsKeyList = _settings.keys.toList(growable: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Ustawienia'),
      ),
      body: ListView.builder(
        itemCount: settingsKeyList.length,
        itemBuilder: (context, idx) {
          var key = settingsKeyList[idx];
          var setting = _settings[key];
          var settingType = setting[_SettingValueMap.TYPE];
          var settingValue = setting[_SettingValueMap.VALUE];
          Widget getChooseWidget() {
            switch(settingType) {
              case _SettingValueType.BOOL:
                return CheckboxListTile(
                  title: Text(_settingsTitle[key]),
                  value: settingValue,
                  onChanged: (value) {
                    setState(() {
                      _settings[key][_SettingValueMap.VALUE] = value;
                      _saveSettings(key, settingType, value);
                    });
                  },
                );
            }
            return null;
          }
          return getChooseWidget();
        }
      ),
    );
  }

  void _saveSettings(String key, _SettingValueType type, dynamic value) {
    switch(type) {
      case _SettingValueType.BOOL:
        _prefs.setBool(key, value);
        return null;
    }
  }


}