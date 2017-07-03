require './constants.rb'
require 'bundler/setup'
require 'discordrb'
require 'dotenv'
require 'json'
Dotenv.load("../.env")

description = Constants::DESCRIPTION

bot = Discordrb::Commands::CommandBot.new(token: ENV["TOKEN"], client_id: ENV["CLIENT_ID"], prefix: "!") 

bot.run :async

bot.command(:random, :description => description) do |event, args, *another_args|

  # 発言したユーザーからランダマイズ対象となるチャンネルを取得する
  voice_channel = event.author.voice_channel

  # 発言したユーザーがボイスチャンネルに入っていない場合はその旨のメッセージを出す
  res = "ボイスチャンネルに入ってからランダマイズしてください" unless voice_channel
  return event.respond(res) if res

  if args

    # 第二引数以降も考慮する
    args += another_args.join

    # 引数に「ブキ」の文字があればブキランダム
    weapon_random_flag = true if args.match(/ブキ/)

    # 引数に「サブ」の文字があればサブランダム
    sub_random_flag = true if args.match(/サブ/)

    # 引数に「スペシャル」の文字があればスペシャルランダム
    special_random_flag = true if args.match(/スペシャル/)

    # ブキランダム、サブランダム、スペシャルランダムは共存しない
    if weapon_random_flag && sub_random_flag || weapon_random_flag && special_random_flag || sub_random_flag && special_random_flag
      res = "ブキ、サブ、スペシャルのうち一つしかランダムに指定できません"
      event.respond(res)
      return
    end

    # 引数に「ギア」の文字があればギアランダム
    gear_random_flag = true if args.match(/ギア/)

    # 引数が上記以外の場合は不正の引数とする
    unless weapon_random_flag || sub_random_flag || special_random_flag || gear_random_flag  
      res = "ブキ、サブ、スペシャル、ギアのいずれかを指定してください"
      event.respond(res)
      return
    end
  else
    # 引数がなければブキランダムとして扱う
    weapon_random_flag = true
  end

  current_users = ""

  res = "RANDOMIZE!!\nーーーーーーーーーーーーー\n"
  res << "ルール: 　#{Constants::SPLATOON_RULE.sample}\n"
  res << "ステージ: #{Constants::SPLATOON_STAGE.sample}\n"

  voice_channel.users.each do |user|
    res << "ーーーーーーーーーーーーー\n"
    res << "__#{user.username}__\n"
    if weapon_random_flag
      res << "　ブキ: #{Constants::SPLATOON_WEAPONS.sample}\n"  
    end
    if sub_random_flag
      res << "　サブ: #{Constants::SPLATOON_SUB_WEAPONS.sample}\n"
    end
    if special_random_flag
      res << "　スペシャル: #{Constants::SPLATOON_SPECIAL_WEAPONS.sample}\n"
    end
    if gear_random_flag
      head_gears = Constants::SPLATOON_GEAR_POWER_COMMON + Constants::SPLATOON_GEAR_POWER_HEAD
      body_gears = Constants::SPLATOON_GEAR_POWER_COMMON + Constants::SPLATOON_GEAR_POWER_BODY
      foot_gears = Constants::SPLATOON_GEAR_POWER_COMMON + Constants::SPLATOON_GEAR_POWER_FOOT

      res << "　アタマ: #{head_gears.sample}\n　フク: #{body_gears.sample}\n　クツ: #{foot_gears.sample}\n"
    end
  end
  event.respond(res)
end

bot.sync
