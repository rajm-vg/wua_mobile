import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wua_mobile/core/constants/env_config.dart';

void main() {
  tearDown(() {
    dotenv.clean();
    EnvConfig.setEnvironment(AppEnvironment.development);
  });

  group('EnvConfig', () {
    test('resolveEnvironment maps flavor names accurately', () {
      expect(EnvConfig.resolveEnvironment('dev'), AppEnvironment.development);
      expect(
        EnvConfig.resolveEnvironment('development'),
        AppEnvironment.development,
      );
      expect(EnvConfig.resolveEnvironment('qa'), AppEnvironment.qa);
      expect(EnvConfig.resolveEnvironment('QA'), AppEnvironment.qa);
      expect(EnvConfig.resolveEnvironment('uat'), AppEnvironment.uat);
      expect(EnvConfig.resolveEnvironment('prod'), AppEnvironment.production);
      expect(
        EnvConfig.resolveEnvironment('production'),
        AppEnvironment.production,
      );
      expect(EnvConfig.resolveEnvironment(''), AppEnvironment.development);
      expect(EnvConfig.resolveEnvironment('unknown'), AppEnvironment.development);
    });

    test('setEnvironment updates envFileName to expected dot-env file', () {
      EnvConfig.setEnvironment(AppEnvironment.development);
      expect(EnvConfig.envFileName, '.env.dev');

      EnvConfig.setEnvironment(AppEnvironment.qa);
      expect(EnvConfig.envFileName, '.env.qa');

      EnvConfig.setEnvironment(AppEnvironment.uat);
      expect(EnvConfig.envFileName, '.env.uat');

      EnvConfig.setEnvironment(AppEnvironment.production);
      expect(EnvConfig.envFileName, '.env.prod');
    });

    test('loads QA variables cleanly from .env.qa', () {
      final qaContent = File('.env.qa').readAsStringSync();
      dotenv.loadFromString(envString: qaContent);

      expect(EnvConfig.buildFlavor, 'qa');
      expect(EnvConfig.isQa, isTrue);
      expect(EnvConfig.isDevelopment, isFalse);
      expect(EnvConfig.isProduction, isFalse);
      expect(EnvConfig.baseUrl, 'https://api.wrd.techvgi.com');
      expect(EnvConfig.apiKey, 'qa_api_key');
      expect(EnvConfig.connectTimeout, 30000);
      expect(EnvConfig.receiveTimeout, 30000);
      expect(EnvConfig.enableLogging, isTrue);
      expect(EnvConfig.enableDemoFallback, isFalse);
      expect(EnvConfig.easebuzzPayMode, 'test');
    });

    test('loads Dev variables cleanly from .env.dev', () {
      final devContent = File('.env.dev').readAsStringSync();
      dotenv.loadFromString(envString: devContent);

      expect(EnvConfig.buildFlavor, 'development');
      expect(EnvConfig.isDevelopment, isTrue);
      expect(EnvConfig.isQa, isFalse);
      expect(EnvConfig.baseUrl, 'http://192.168.10.146:7010');
      expect(EnvConfig.apiKey, 'dev_api_key');
      expect(EnvConfig.enableLogging, isTrue);
      expect(EnvConfig.enableDemoFallback, isFalse);
      expect(EnvConfig.easebuzzPayMode, 'test');
    });

    test('returns safe defaults when dotenv is not initialized', () {
      dotenv.clean();
      expect(EnvConfig.baseUrl, 'http://localhost:7010');
      expect(EnvConfig.buildFlavor, 'development');
      expect(EnvConfig.easebuzzPayMode, 'test');
      expect(EnvConfig.enableLogging, isFalse);
      expect(EnvConfig.enableDemoFallback, isFalse);
    });
  });
}
