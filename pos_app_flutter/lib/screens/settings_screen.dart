import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pos_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _urlController = TextEditingController();
  bool _isTestingConnection = false;
  String? _connectionTestResult;

  @override
  void initState() {
    super.initState();
    final provider = context.read<PosProvider>();
    _urlController.text = provider.apiBaseUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTestingConnection = true;
      _connectionTestResult = null;
    });

    final provider = context.read<PosProvider>();
    
    try {
      // 一時的にURLを設定してテスト
      await provider.setApiBaseUrl(_urlController.text);
      final isConnected = await provider.checkApiConnection();
      
      setState(() {
        _connectionTestResult = isConnected 
            ? '接続成功: APIサーバーに正常に接続できました'
            : '接続失敗: APIサーバーに接続できませんでした';
      });
    } catch (e) {
      setState(() {
        _connectionTestResult = '接続エラー: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isTestingConnection = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        centerTitle: true,
      ),
      body: Consumer<PosProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // データソース設定
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'データソース設定',
                          style: AppConstants.titleStyle,
                        ),
                        const SizedBox(height: AppConstants.defaultMargin),
                        
                        Text(
                          '商品データと購入処理の方法を選択してください',
                          style: AppConstants.captionStyle,
                        ),
                        const SizedBox(height: AppConstants.defaultPadding),
                        
                        // API使用切り替え
                        SwitchListTile(
                          title: const Text('API サーバーを使用'),
                          subtitle: Text(provider.useApi 
                              ? 'バックエンドAPIから商品データを取得します'
                              : 'モックデータを使用します（テスト用）'),
                          value: provider.useApi,
                          onChanged: (value) {
                            provider.setApiUsage(value);
                          },
                          activeColor: AppConstants.primaryColor,
                        ),
                        
                        // 現在の状態表示
                        Container(
                          padding: const EdgeInsets.all(AppConstants.defaultMargin),
                          decoration: BoxDecoration(
                            color: provider.useApi 
                                ? AppConstants.primaryColor.withOpacity(0.1)
                                : AppConstants.warningColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                provider.useApi ? Icons.cloud : Icons.storage,
                                color: provider.useApi 
                                    ? AppConstants.primaryColor
                                    : AppConstants.warningColor,
                              ),
                              const SizedBox(width: AppConstants.defaultMargin),
                              Expanded(
                                child: Text(
                                  provider.useApi 
                                      ? '現在: APIサーバーモード'
                                      : '現在: モックデータモード',
                                  style: AppConstants.bodyStyle.copyWith(
                                    color: provider.useApi 
                                        ? AppConstants.primaryColor
                                        : AppConstants.warningColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: AppConstants.defaultPadding),
                
                // API設定（API使用時のみ表示）
                if (provider.useApi) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'API設定',
                            style: AppConstants.titleStyle,
                          ),
                          const SizedBox(height: AppConstants.defaultMargin),
                          
                          Text(
                            'バックエンドAPIサーバーのベースURLを設定してください',
                            style: AppConstants.captionStyle,
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          
                          // APIベースURL設定
                          TextFormField(
                            controller: _urlController,
                            decoration: const InputDecoration(
                              labelText: 'API ベースURL',
                              hintText: 'http://localhost:8000',
                              prefixIcon: Icon(Icons.link),
                            ),
                            keyboardType: TextInputType.url,
                          ),
                          
                          const SizedBox(height: AppConstants.defaultPadding),
                          
                          // 接続テストボタン
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: ElevatedButton.icon(
                                  onPressed: _isTestingConnection ? null : _testConnection,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppConstants.primaryColor,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(100, 40),
                                  ),
                                  icon: _isTestingConnection
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Icon(Icons.wifi_find),
                                  label: Text(_isTestingConnection ? '接続テスト中...' : '接続テスト'),
                                ),
                              ),
                              const SizedBox(width: AppConstants.defaultMargin),
                              Expanded(
                                flex: 1,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await provider.setApiBaseUrl(_urlController.text);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('API URLを保存しました'),
                                          backgroundColor: AppConstants.successColor,
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(60, 40),
                                  ),
                                  child: const Text('保存'),
                                ),
                              ),
                            ],
                          ),
                          
                          // 接続テスト結果表示
                          if (_connectionTestResult != null) ...[
                            const SizedBox(height: AppConstants.defaultPadding),
                            Container(
                              padding: const EdgeInsets.all(AppConstants.defaultMargin),
                              decoration: BoxDecoration(
                                color: _connectionTestResult!.contains('成功')
                                    ? AppConstants.successColor.withOpacity(0.1)
                                    : AppConstants.errorColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                                border: Border.all(
                                  color: _connectionTestResult!.contains('成功')
                                      ? AppConstants.successColor.withOpacity(0.3)
                                      : AppConstants.errorColor.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _connectionTestResult!.contains('成功')
                                        ? Icons.check_circle_outline
                                        : Icons.error_outline,
                                    color: _connectionTestResult!.contains('成功')
                                        ? AppConstants.successColor
                                        : AppConstants.errorColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppConstants.defaultMargin / 2),
                                  Expanded(
                                    child: Text(
                                      _connectionTestResult!,
                                      style: AppConstants.captionStyle.copyWith(
                                        color: _connectionTestResult!.contains('成功')
                                            ? AppConstants.successColor
                                            : AppConstants.errorColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: AppConstants.defaultPadding),
                
                // モックデータ情報（モック使用時のみ表示）
                if (!provider.useApi) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'モックデータ情報',
                            style: AppConstants.titleStyle,
                          ),
                          const SizedBox(height: AppConstants.defaultMargin),
                          
                          Text(
                            'テスト用のサンプル商品データを使用しています',
                            style: AppConstants.captionStyle,
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          
                          Container(
                            padding: const EdgeInsets.all(AppConstants.defaultMargin),
                            decoration: BoxDecoration(
                              color: AppConstants.warningColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'サンプル商品コード:',
                                  style: AppConstants.captionStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text('• 4901085123456 - ボールペン（黒）¥150'),
                                const Text('• 4901085123457 - ボールペン（青）¥150'),
                                const Text('• 4901085111111 - ノート（A4・横罫）¥200'),
                                const Text('• 4901085333333 - ホッチキス（中型）¥800'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}