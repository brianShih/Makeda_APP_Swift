//
//  CountriesNCities.swift
//  Makeda
//
//  Created by Brian on 2018/11/28.
//  Copyright © 2018 breadcrumbs.tw. All rights reserved.
//

import Foundation

struct GloupID{
    let all_groupID = 0
    let Taiwan_groupID = 1
    let Japan_groupID = 2
    let China_groupID = 3
}

struct TownUnit {
    let list = [
        "市",
        "村",
        "町",
        "區",
        "鄉",
        "鎮"
    ]
    let notIncludes = [
        "超市",
        "園區"
    ]
}

struct ppMainTags {
    let list = [
        "#食",
        "#衣",
        "#住",
        "#行",
        "#景",
        "#購物"
    ]
}

struct Countries {
    let list = [
    "台灣",
    "日本",
    "中國"
    ]
}

struct CountryCode {
    let list = [
        "+886",
        "+81",
        "+86",
    ]
}

struct Cities {
    let citiesOfAll = "所有"
    let citiesOfTaiwan = [
        "所有", "彰化縣", "南投縣","雲林縣",
        "嘉義縣", "台南市", "高雄市", "屏東縣", "台東縣",
        "花蓮縣", "宜蘭縣", "基隆市", "新北市", "台北市",
        "桃園市", "新竹縣", "苗栗縣", "台中市",
        "澎湖縣", "金門縣", "連江縣"]
    let citiesOfJapan = [
        "所有", "北海道", "青森縣", "岩手縣", "宮城縣", "秋田縣", "山形縣","福島縣",
        "茨城縣", "栃木縣", "群馬縣", "埼玉縣", "千葉縣", "東京都", "神奈川縣",
        "新潟縣", "富山縣", "石川縣", "福井縣", "山梨縣", "長野縣", "岐阜縣", "靜岡縣", "愛知縣",
        "三重縣", "滋賀縣", "京都府", "大阪府", "兵庫縣", "奈良縣", "和歌山縣",
        "鳥取縣", "島根縣", "岡山縣", "廣島縣", "山口縣",
        "德島縣", "香川縣", "愛媛縣", "高知縣",
        "福岡縣", "佐賀縣", "長崎縣", "熊本縣", "大分縣", "宮崎縣", "鹿兒島縣",
        "沖繩縣"]
    let citiesOfChina = [
        "所有", "北京市", "天津市", "上海市", "重慶市",
        "河北省", "山西省", "遼寧省", "吉林省", "黑龍江省",
        "江蘇省", "浙江省", "安徽省", "福建省", "江西省", "山東省", "河南省",
        "湖北省", "湖南省", "廣東省", "海南省", "四川省", "貴州省", "雲南省",
        "陝西省", "甘肅省", "青海省",
        "內蒙古", "廣西", "西藏", "寧夏", "新疆",
        "香港", "澳門"
    ]
}
