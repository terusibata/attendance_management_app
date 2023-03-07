# 勤怠管理システム

## Requirement
ruby 3.1.0 または、より新しいバージョン

rails 7.0.4 または、より新しいバージョン

## Usage
```
bundle install
rails db:migrate
rails db:seed
rails s
```

## login
| 名前 | メールアドレス | パスワード | 管理者権限 | 
|:-----------|------------:|:------------:|:------------:|
| 管理者アカウント | admin@test.com | admintest | あり |
| 従業員アカウント1 | user1@test.com | usertest1 | なし |
| 従業員アカウント2 | user2@test.com | usertest2 | なし |
| 従業員アカウント3 | user3@test.com | usertest3 | なし |

## TODO
- 管理者：全従業員の年表示での勤怠確認
- 従業員：年表示での勤怠確認
- 編集履歴を保存、表示機能
- 勤怠状況のCSV等での書き出しに対応