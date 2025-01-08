# セキュリティ課題
# データベース接続情報の保護 → 環境変数/設定ファイルの作成/暗号化

require 'webrick'
require 'json'
require 'sqlite3'

# SQLiteデータベースへの接続設定
db = SQLite3::Database.new 'hogehoge.db'

# テーブルが存在しない場合は作成
db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL
  );
SQL

# サーバーのドキュメントルートを設定（同一フォルダ内のindex.htmlを指す）
root = File.expand_path '.'

server = WEBrick::HTTPServer.new(Port: 3000, DocumentRoot: root)

# データの追記
server.mount_proc '/input' do |req, res|
  if req.request_method == 'OPTIONS'
    res['Access-Control-Allow-Origin'] = '*'
    res['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    res['Access-Control-Allow-Headers'] = 'Content-Type'
    res.status = 200
    return # OPTIONSの処理をここで終了

  elsif req.request_method == 'POST'
    # リクエストからjsonデータを取得
    data = req.body
    parsed_data = JSON.parse(data)

    # コンソールに出力
    puts "Received JSON data: #{parsed_data['userName']}"

    # プレースホルダでsqlインジェクション対策
    db.execute('INSERT INTO users (name) VALUES (?)', [parsed_data['userName']])

    # レスポンスにメッセージを設定
    res.body = "Received JSON data:#{parsed_data['userName']}"
    # res.body='Hello World!!'
  end
end

# データの出力
server.mount_proc '/output' do |req, res|
  begin
    # データベースからデータの取得
    result = db.execute('SELECT * FROM users;')

    # データをJSON形式に変換
    json_result = result.map { |row| { id: row[0], name: row[1] } }.to_json

    # コンソールに出力
    # puts "Received JSON data: #{json_result}"

    # レスポンスにデータを設定
    res.content_type = 'application/json'
    res.body = json_result
  rescue => e
    puts "Error: #{e.message}"
    puts e.backtrace
  end
end

trap 'INT' do
  server.shutdown
end

server.start
