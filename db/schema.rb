# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20230501003433) do

  create_table "departments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "compCode", limit: 60, null: false
    t.string "departCode", limit: 50, null: false
    t.string "departDescription", limit: 80, null: false
    t.string "departHod", limit: 80, default: "", null: false
    t.integer "departNumberofemp", default: 0, null: false
    t.string "departEmpcode", limit: 30, default: "", null: false
    t.string "departType", limit: 30, default: "", null: false
    t.string "subdepartment", limit: 20, default: "", null: false
    t.string "helpdesk", limit: 1, default: "N", null: false
    t.string "cordinate", limit: 1, default: "N", null: false
    t.string "cordinatevalue", limit: 100, default: "", null: false
    t.string "cordnatorthird", limit: 30, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "designations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "compcode", limit: 60, null: false
    t.string "desicode", limit: 45, null: false
    t.string "ds_description", limit: 80, null: false
    t.string "ds_type", limit: 30, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "holidays", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "compCode", limit: 60, null: false
    t.string "dateYear", limit: 20, null: false
    t.string "description", limit: 200, null: false
    t.string "holidaytype", limit: 20, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "magazine_receipts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci" do |t|
    t.string "mr_code", limit: 30, null: false
    t.string "mr_compcode", limit: 30, null: false
    t.string "mr_amount", limit: 30, null: false
    t.string "mr_currencyamount", limit: 30, null: false
    t.string "mr_bankname", limit: 30, null: false
    t.string "mr_magazine", limit: 30, null: false
    t.string "mr_member", limit: 30, null: false
    t.string "mr_subscription", limit: 30, null: false
    t.string "mr_paymentmode", limit: 30, null: false
    t.string "mr_manualrectnum", limit: 30, null: false
    t.date "mr_manualrectdate", null: false
    t.string "mr_accountrectnum", limit: 30, null: false
    t.date "mr_accountrectdate", null: false
    t.string "mr_documentnum", limit: 30, null: false
    t.string "mr_modifiedby", limit: 60, null: false
    t.string "mr_createdby", limit: 60, null: false
    t.string "mr_status", limit: 1, default: "Y", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "member_logs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci" do |t|
    t.string "ml_title", limit: 200, null: false
    t.string "ml_compcode", limit: 30, null: false
    t.string "ml_member_code", limit: 30, null: false
    t.string "ml_description", limit: 500, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "members", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci" do |t|
    t.string "mbr_code", limit: 30, null: false
    t.string "mbr_name", limit: 60, null: false
    t.string "mbr_compcode", limit: 30, null: false
    t.string "mbr_state", limit: 30, null: false
    t.string "mbr_status", limit: 1, default: "Y", null: false
    t.string "mbr_city", limit: 30, null: false
    t.string "mbr_district", limit: 30, null: false
    t.string "mbr_email", limit: 30, null: false
    t.string "mbr_full_address", limit: 200, null: false
    t.string "mbr_mobile", limit: 30, null: false
    t.string "mbr_mobile2", limit: 30
    t.string "mbr_pincode", limit: 30, null: false
    t.string "mbr_addr_l1", limit: 200, null: false
    t.string "mbr_addr_l2", limit: 200
    t.string "mbr_co_name", limit: 30, null: false
    t.string "mbr_co_title", limit: 30, null: false
    t.date "mbr_dob"
    t.string "mbr_education", limit: 30
    t.string "mbr_gender", limit: 30
    t.string "mbr_occupation", limit: 30
    t.string "mbr_pan", limit: 200
    t.string "mbr_reason_change", limit: 30
    t.string "mbr_title", limit: 30, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mst_accomodation_allotments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "aa_compcode", limit: 30, null: false
    t.string "aa_alotmentno", limit: 30, null: false
    t.date "aa_alotmentdate", null: false
    t.string "aa_depcode", limit: 30, null: false
    t.string "aa_sewadarcode", limit: 60, null: false
    t.string "aa_addtype", limit: 1, null: false
    t.integer "aa_address", default: 0, null: false
    t.string "aa_declaretaking", limit: 1, default: "", null: false
    t.string "aa_attachment", limit: 60, default: "", null: false
    t.string "aa_status", limit: 1, default: "N", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["aa_alotmentno"], name: "aa_alotmentno", unique: true
  end

  create_table "mst_accomodation_details", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "ad_compcode", limit: 30, null: false
    t.integer "ad_accomodtype", default: 0, null: false
    t.string "ad_belongs", limit: 1, null: false
    t.string "ad_address", limit: 300, default: "", null: false
    t.integer "ad_noofrooms", default: 0, null: false
    t.string "ad_state", limit: 30, default: "", null: false
    t.string "ad_district", limit: 30, default: "", null: false
    t.string "ad_city", limit: 30, default: "", null: false
    t.string "ad_typeofkitechen", limit: 30, default: "", null: false
    t.string "ad_typeofwashroom", limit: 30, default: "", null: false
    t.string "ad_pincode", limit: 20, default: "", null: false
    t.string "ad_allotmentno", limit: 30, default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mst_accomodation_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "at_compcode", limit: 30, null: false
    t.string "at_description", limit: 120, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mst_addresses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci" do |t|
    t.string "adr_code", limit: 30, null: false
    t.string "adr_name", limit: 60, null: false
    t.string "adr_compcode", limit: 30, null: false
    t.string "adr_membercode", limit: 30, null: false
    t.string "adr_state", limit: 30, null: false
    t.string "adr_country", limit: 60, null: false
    t.string "adr_status", limit: 1, default: "Y", null: false
    t.string "adr_city", limit: 30, null: false
    t.string "adr_district", limit: 30, null: false
    t.string "adr_email", limit: 30, null: false
    t.string "adr_fulladdress", limit: 400, null: false
    t.string "adr_mobile", limit: 30, null: false
    t.string "adr_pincode", limit: 30, null: false
    t.string "adr_line1", limit: 200, null: false
    t.string "adr_line2", limit: 200
  end

  create_table "mst_bakshish_scales", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "bs_compcode", limit: 30, null: false
    t.string "bs_years", limit: 15, null: false
    t.date "bs_ashdate", null: false
    t.float "bs_fromvalue", limit: 53, default: 0.0, null: false
    t.float "bs_uptovalue", limit: 53, default: 0.0, null: false
    t.float "bs_paylimit", limit: 53, default: 0.0, null: false
    t.string "bs_month_rule_first", limit: 5, default: "", null: false
    t.string "bs_sewpercent_first", limit: 5, default: "", null: false
    t.string "bs_sewpercent_second", limit: 5, default: "", null: false
    t.string "bs_month_rule_sec", limit: 5, default: "", null: false
    t.string "bs_condition", limit: 60, default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mst_bank_lists", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "bl_compcode", limit: 30, null: false
    t.string "bl_name", limit: 80, null: false
    t.string "bl_code", limit: 30, null: false
    t.string "bl_ifsccode", limit: 20, default: "", null: false
    t.string "bl_address", default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mst_birthday_wishes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "bw_compcode", limit: 30, null: false
    t.string "bw_title_enlish", limit: 350, null: false
    t.string "bw_title_hindi", limit: 350, null: false, collation: "utf8mb3_bin"
    t.string "bw_description_hindi", limit: 500, null: false, collation: "utf8mb3_bin"
    t.string "bw_bottom_bless", limit: 350, null: false, collation: "utf8mb3_bin"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mst_branch_lists", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "bl_compcode", limit: 30, null: false
    t.string "bl_type", limit: 30, null: false
    t.string "bl_branchcode", limit: 30, null: false
    t.string "bl_branchname", limit: 120, null: false
    t.string "bl_statecode", limit: 30, default: "", null: false
    t.string "bl_citycode", limit: 30, default: "", null: false
    t.string "bl_districtcode", limit: 30, default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mst_branches", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "bch_compcode", limit: 30, null: false
    t.string "bch_branchcode", limit: 30, null: false
    t.string "bch_branchnumber", limit: 30, default: "", null: false
    t.string "bch_zonecode", limit: 30, default: "", null: false
    t.string "bch_districtcode", limit: 30, default: "", null: false
    t.string "bch_branchname", limit: 80, default: "", null: false
    t.string "bch_address", default: "", null: false
    t.string "bch_bhawan", limit: 1, default: "N", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mst_cities", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "ct_compcode", limit: 30, null: false
    t.string "ct_statecode", limit: 10, null: false
    t.string "ct_districtcode", limit: 10, null: false
    t.string "ct_citycode", limit: 10, null: false
    t.string "ct_description", limit: 80, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mst_companies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "cmp_companycode", limit: 20, null: false
    t.string "cmp_companyname", limit: 60, null: false
    t.string "cmp_tradename", limit: 60, null: false
    t.string "cmp_gstname", limit: 30, null: false
    t.string "cmp_typeofbussiness", limit: 250, null: false
    t.string "cmp_addressline1", limit: 225, null: false
    t.string "cmp_addressline2", limit: 225, null: false
    t.string "cmp_addressline3", limit: 225, null: false
    t.string "cmp_telephonenumber", limit: 12, default: "0", null: false
    t.string "cmp_cell_number", limit: 11, default: "0", null: false
    t.integer "cmp_countrycode", default: 0, null: false
    t.integer "cmp_stateandcode", default: 0, null: false
    t.string "cmp_email", limit: 100, null: false
    t.string "cmp_bankname", limit: 60, null: false
    t.string "cmp_bankbranch", limit: 100, null: false
    t.string "cmp_accountnumber", limit: 30, null: false
    t.string "cmp_pannumber", limit: 25, null: false
    t.string "cmp_adharnumber", limit: 25, null: false
    t.string "cmp_termandcondition", null: false
    t.string "cmp_declaration", limit: 200, null: false
    t.string "cmp_logos", limit: 100, null: false
    t.string "cmp_bankifsccode", limit: 20, null: false
    t.string "cmp_compidentity_no", limit: 36, null: false
    t.string "cmp_otp", limit: 10, null: false
    t.string "cmp_signs", limit: 100, null: false
    t.string "cmp_show_logo", limit: 1, default: "N", null: false
    t.string "cmp_show_pay_pop", limit: 1, default: "N", null: false
    t.string "cmp_credit_debit_sgn", limit: 1, default: "N", null: false
    t.string "cmp_proddup_allowed", limit: 1, default: "N", null: false
    t.string "cmp_raw_material", limit: 1, default: "Y", null: false
    t.string "cmp_multi_loc", limit: 1, default: "N", null: false
    t.string "cmp_status", limit: 1, null: false
    t.string "cmp_unitname", limit: 62, null: false
    t.string "cmp_gst_registered", limit: 1, default: "N", null: false
    t.string "cmp_godam_allowed", limit: 1, default: "N", null: false
    t.string "cmp_negative_stock", limit: 1, default: "N", null: false
    t.string "cmp_show_unbilled", limit: 1, default: "N", null: false
    t.string "comp_ad_code", limit: 60, default: "", null: false
    t.string "comp_use_code", limit: 30, default: "", null: false
    t.integer "comp_redeemscale", default: 0, null: false
    t.float "cmp_memb_purlimit", limit: 53, default: 0.0, null: false
    t.string "cmp_processabort", limit: 2, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cmp_companycode"], name: "cmp_companycode", unique: true
    t.index ["cmp_processabort"], name: "cmp_processabort"
  end

  create_table "mst_complaint_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci" do |t|
    t.string "ct_name", limit: 60, null: false
    t.string "ct_compcode", limit: 30, null: false
    t.string "ct_code", limit: 30, null: false
    t.string "ct_status", limit: 1, default: "Y", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mst_couriers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci" do |t|
    t.string "cr_name", limit: 60, null: false
    t.string "cr_compcode", limit: 30, null: false
    t.string "cr_code", limit: 30, null: false
    t.string "cr_status", limit: 1, default: "Y", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mst_credit_leaves", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "cls_compcode", limit: 30, null: false
    t.integer "cls_year", default: 0, null: false
    t.integer "cls_month", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mst_currencies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci" do |t|
    t.string "cur_name", limit: 60, null: false
    t.string "cur_compcode", limit: 30, null: false
    t.string "cur_code", limit: 30, null: false
    t.string "cur_status", limit: 1, default: "Y", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mst_dispatch_modes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci" do |t|
    t.string "dm_name", limit: 60, null: false
    t.string "dm_compcode", limit: 30, null: false
    t.string "dm_code", limit: 30, null: false
    t.string "dm_status", limit: 1, default: "Y", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mst_dispatch_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci" do |t|
    t.string "dt_name", limit: 60, null: false
    t.string "dt_compcode", limit: 30, null: false
    t.string "dt_code", limit: 30, null: false
    t.string "dt_status", limit: 1, default: "Y", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mst_districts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "dts_compcode", limit: 30, null: false
    t.string "dts_statecode", limit: 10, null: false
    t.string "dts_districtcode", limit: 10, null: false
    t.string "dts_description", limit: 60, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mst_educational_parameters", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "ep_compcode", limit: 30, null: false
    t.integer "ep_aglimit", default: 0, null: false
    t.integer "ep_fromfirstto", limit: 1, default: 0, null: false
    t.integer "ep_uptofifth", limit: 1, default: 0, null: false
    t.float "ep_firstfifthamt", limit: 53, default: 0.0, null: false
    t.integer "ep_fromsixto", limit: 1, default: 0, null: false
    t.integer "ep_uptotwelth", limit: 1, default: 0, null: false
    t.float "ep_sixtotwelthamt", limit: 53, default: 0.0, null: false
    t.float "ep_univfirstyearamt", limit: 53, default: 0.0, null: false
    t.float "ep_univsecondyearamt", limit: 53, default: 0.0, null: false
    t.float "ep_univthirdamt", limit: 53, default: 0.0, null: false
    t.float "ep_postgraduateamt", limit: 53, default: 0.0, null: false
    t.float "ep_postgraduatesecamt", limit: 53, default: 0.0, null: false
    t.float "ep_docterateamt", limit: 53, default: 0.0, null: false
    t.float "ep_doctoratesecamt", limit: 53, default: 0.0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mst_escalation_matrices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci" do |t|
    t.string "em_name", limit: 60, null: false
    t.string "em_compcode", limit: 30, null: false
    t.string "em_code", limit: 30, null: false
    t.string "em_status", limit: 1, default: "Y", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mst_head_offices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "hof_compcode", limit: 30, null: false
    t.string "hof_loccode", limit: 30, default: "", null: false
    t.string "hof_description", limit: 120, default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mst_hr_parameter_accomodations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "hpa_compcode", limit: 30, null: false
    t.integer "hpa_types", null: false
    t.float "hpa_value", limit: 53, default: 0.0, null: false
    t.float "hpa_rates", limit: 53, default: 0.0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mst_hr_parameter_heads", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "hph_compcode", limit: 30, null: false
    t.float "hph_licpay", limit: 53, default: 0.0, null: false
    t.float "hph_mandalpay", limit: 53, default: 0.0, null: false
    t.float "hph_sewapay", limit: 53, default: 0.0, null: false
    t.float "hph_suminsured", limit: 53, default: 0.0, null: false
    t.float "hph_monthly_amt", limit: 53, default: 0.0, null: false
    t.float "hph_policymandalpay", limit: 53, default: 0.0, null: false
    t.float "hph_policysewapay", limit: 53, default: 0.0, null: false
    t.float "hph_dependent", limit: 53, default: 0.0, null: false
    t.float "hph_parent", limit: 53, default: 0.0, null: false
    t.float "hph_dependentsec", limit: 53, default: 0.0, null: false
    t.float "hph_parenetsec", limit: 53, default: 0.0, null: false
    t.float "hph_dependentthird", limit: 53, default: 0.0, null: false
    t.float "hph_parenthird", limit: 53, default: 0.0, null: false
    t.float "hph_policyslabtwo_sumins", limit: 53, default: 0.0, null: false
    t.float "hph_policytwo_monthlyamt", limit: 53, default: 0.0, null: false
    t.float "hph_policytwo_mandalpay", limit: 53, default: 0.0, null: false
    t.float "hph_policytwo_sewapay", limit: 53, default: 0.0, null: false
    t.float "hph_policythree_sumins", limit: 53, default: 0.0, null: false
    t.float "hph_policythree_monthly", limit: 53, default: 0.0, null: false
    t.float "hph_policythree_mandalpay", limit: 53, default: 0.0, null: false
    t.float "hph_policythree_sewpay", limit: 53, default: 0.0, null: false
    t.float "hph_incometaxpercent", limit: 24, default: 0.0, null: false
    t.float "hph_deductedlimited", limit: 53, default: 0.0, null: false
    t.float "hph_consumption", limit: 53, default: 0.0, null: false
    t.float "hph_aplicablema", limit: 53, default: 0.0, null: false
    t.integer "hph_years", default: 0, null: false
    t.integer "hph_months", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mst_hr_parameter_ranges", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "hpr_compcode", limit: 30, null: false
    t.float "hpr_rangefrom", limit: 53, default: 0.0, null: false
    t.float "hpr_rangeto", limit: 53, default: 0.0, null: false
    t.float "hpr_rate1", limit: 53, default: 0.0, null: false
    t.float "hpr_rate2", limit: 53, default: 0.0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mst_individual_heads", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci" do |t|
    t.string "ih_code", limit: 30, null: false
    t.string "ih_name", limit: 60, null: false
    t.string "ih_compcode", limit: 30, null: false
    t.string "ih_state", limit: 30, null: false
    t.string "ih_status", limit: 1, default: "Y", null: false
    t.string "ih_city", limit: 30, null: false
    t.string "ih_district", limit: 30, null: false
    t.string "ih_phone", limit: 30, null: false
    t.string "ih_email", limit: 30, null: false
    t.string "ih_address", limit: 200, null: false
    t.string "ih_mobile", limit: 30, null: false
    t.string "ih_dispatch_mode", limit: 30, null: false
    t.string "ih_dispatch_type", limit: 30, null: false
    t.string "ih_country", limit: 30, null: false
    t.string "ih_pincode", limit: 30, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mst_languages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci" do |t|
    t.string "lang_name", limit: 60, null: false
    t.string "lang_compcode", limit: 30, null: false
    t.string "lang_code", limit: 30, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", limit: 1, default: "Y"
  end

  create_table "mst_leave_closing_balanaces", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mst_leaves", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "attend_compcode", limit: 60, null: false
    t.string "attend_category", limit: 80, null: false
    t.string "attend_leaveCode", limit: 30, null: false
    t.string "attend_leavetype", limit: 60, null: false
    t.string "attend_paidleave", limit: 1, default: "B", null: false
    t.string "attend_balancesleave", limit: 1, default: "B", null: false
    t.string "attend_runworking", limit: 1, default: "B", null: false
    t.string "attend_enchash", limit: 1, default: "B", null: false
    t.string "attend_balanceforprevious", limit: 1, default: "B", null: false
    t.float "attend_annualquota", limit: 24, default: 0.0, null: false
    t.float "attend_accumulationleave", limit: 24, default: 0.0, null: false
    t.string "attend_creditrule", limit: 30, default: "", null: false
    t.float "attend_creditruledays", limit: 24, default: 0.0, null: false
    t.string "attend_mergeleave", limit: 1, default: "", null: false
    t.string "attend_sundayleave", limit: 1, default: "", null: false
    t.string "attend_whocanapply", limit: 30, default: "", null: false
    t.string "attend_periodapply", limit: 50, default: "", null: false
    t.string "attend_leaveavailby", limit: 1, default: "", null: false
    t.integer "attend_totalsewarequired", default: 0, null: false
    t.string "attend_halfpermisable", limit: 1, default: "N", null: false
    t.float "attend_leavetakenrow", limit: 24, default: 0.0, null: false
    t.float "attend_monthlyleave", limit: 24, default: 0.0, null: false
    t.string "attend_leavereqst", limit: 1, default: "", null: false
    t.float "attend_forefeitdays", limit: 24, default: 0.0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attend_category"], name: "attend_category"
    t.index ["attend_compcode"], name: "attend_compcode"
    t.index ["attend_leaveCode"], name: "attend_leaveCode"
  end

  create_table "mst_ledger_attachments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "sma_compcode", limit: 30, null: false
    t.string "sma_title", limit: 60, default: "", null: false
    t.string "sma_attachment", limit: 60, default: "", null: false
    t.integer "sma_siteno", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mst_ledgers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "lds_compcode", limit: 30, null: false
    t.string "lds_membno", limit: 30, null: false
    t.string "lds_name", limit: 80, null: false
    t.string "lds_type", limit: 40, null: false
    t.string "lds_panno", limit: 120, default: "", null: false
    t.string "lds_adharno", limit: 120, default: "", null: false
    t.string "lds_mobile", limit: 120, default: "", null: false
    t.string "lds_email", limit: 120, default: "", null: false
    t.string "lds_officialemail", limit: 120, default: "", null: false
    t.string "lds_address", limit: 300, default: "", null: false
    t.string "lds_pin", limit: 20, default: "", null: false
    t.integer "lds_state", default: 0, null: false
    t.string "lds_profile", limit: 60, default: "", null: false
    t.string "lds_adhar", limit: 60, default: "", null: false
    t.string "lds_adhar_title", limit: 80, default: "", null: false
    t.string "lds_pan", limit: 60, default: "", null: false
    t.string "lds_pan_title", limit: 80, default: "", null: false
    t.float "lds_openingbal", limit: 53, default: 0.0, null: false
    t.float "lds_closingbal", limit: 53, default: 0.0, null: false
    t.float "lds_unallocatedob", limit: 53, default: 0.0, null: false
    t.float "lds_unallocatedcb", limit: 53, default: 0.0, null: false
    t.string "lds_prefix", limit: 10, default: "", null: false
    t.string "lds_designcode", limit: 30, default: "", null: false
    t.date "lds_dob", null: false
    t.string "lds_personal_mobno", limit: 120, default: "", null: false
    t.integer "lds_location", default: 0, null: false
    t.integer "lds_sublocation", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mst_list_modules", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "lm_compcode", limit: 30, null: false
    t.string "lm_modulecode", limit: 30, null: false
    t.string "lm_modules", limit: 120, null: false
    t.string "lm_departcode", limit: 50, default: "", null: false
    t.string "lm_status", limit: 1, default: "Y", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mst_magazines", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci" do |t|
    t.string "mag_name", limit: 60, null: false
    t.string "mag_compcode", limit: 30, null: false
    t.string "mag_code", limit: 30, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", limit: 1, default: "Y"
    t.string "mag_language", limit: 30, null: false
    t.integer "mag_frequency", null: false
  end

  create_table "mst_marriage_parameters", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "mp_compcode", limit: 30, null: false
    t.float "mp_totalsewaself", limit: 53, default: 0.0, null: false
    t.float "mp_totalsewaengage", limit: 53, default: 0.0, null: false
    t.float "mp_totalsewaformale", limit: 53, default: 0.0, null: false
    t.float "mp_totalsewafemale", limit: 53, default: 0.0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mst_medical_histories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "mh_compcode", limit: 30, null: false
    t.string "mh_code", limit: 30, default: "", null: false
    t.string "mh_other", limit: 50, default: "", null: false
    t.string "mh_answertype", limit: 50, default: "", null: false
    t.string "mh_description", default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mst_postal_directories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci" do |t|
    t.string "pd_code", limit: 30, null: false
    t.string "pd_name", limit: 60, null: false
    t.string "pd_compcode", limit: 30, null: false
    t.string "pd_state", limit: 30, null: false
    t.string "pd_status", limit: 1, default: "Y", null: false
    t.string "pd_city", limit: 30, null: false
    t.string "pd_district", limit: 30, null: false
    t.string "pd_tehsil", limit: 30, null: false
    t.string "pd_country", limit: 30, null: false
    t.string "pd_pincode", limit: 30, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mst_products", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "pr_compcode", limit: 30, null: false
    t.string "pr_name", limit: 80, null: false
    t.string "pr_code", limit: 30, null: false
    t.string "pr_ob", limit: 20, default: "", null: false
    t.string "pr_cb", default: "", null: false
    t.string "pr_img", limit: 500, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mst_qualifications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "ql_compcode", limit: 60, default: "", null: false
    t.string "ql_qualifcode", limit: 35, default: "", null: false
    t.string "ql_qualdescription", limit: 120, default: "", null: false
    t.string "ql_type", limit: 120, default: "", null: false
    t.string "ql_qualification", limit: 120, default: "", null: false
    t.integer "ql_duration", limit: 1, default: 0, null: false
    t.string "ql_isprofessional", limit: 1, default: "N", null: false
    t.string "ql_isinternational", limit: 1, default: "N", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mst_rate_charts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci" do |t|
    t.string "rc_name", limit: 60, null: false
    t.string "rc_compcode", limit: 30, null: false
    t.string "rc_code", limit: 30, null: false
    t.string "rc_status", limit: 1, default: "Y"
    t.integer "rc_amount", null: false
    t.string "rc_subtyp", limit: 30, null: false
    t.string "rc_currency", limit: 30, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "rc_magazine", limit: 30, null: false
  end

  create_table "mst_responsibilities", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "rsp_compcode", limit: 30, null: false
    t.string "rsp_rspcode", limit: 40, null: false
    t.string "rsp_description", limit: 80, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mst_serial_numbers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "sn_compcode", limit: 30, null: false
    t.string "sn_type", limit: 60, null: false
    t.string "sn_prefix", limit: 10, null: false
    t.integer "sn_length", null: false
    t.string "sn_series_sample", limit: 50, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mst_sewadar_categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "sc_compcode", limit: 30, null: false
    t.string "sc_name", limit: 60, null: false
    t.string "sc_catcode", limit: 10, default: "", null: false
    t.integer "sc_position", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mst_sewadar_kyc_banks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "skb_compcode", limit: 30, null: false
    t.string "sbk_sewcode", limit: 30, null: false
    t.string "skb_bank", limit: 80, default: "", null: false
    t.string "skb_branch", limit: 80, default: "", null: false
    t.string "skb_address", default: "", null: false
    t.string "skb_accountno", limit: 80, default: "", null: false
    t.string "skb_ifccocde", limit: 30, default: "", null: false
    t.string "skb_revisedcode", limit: 50, default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["sbk_sewcode"], name: "sbk_sewcode", unique: true
  end

  create_table "mst_sewadar_kyc_qualifications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "skq_compcode", limit: 30, null: false
    t.string "skq_sewcode", limit: 30, null: false
    t.string "skq_qualtype", limit: 40, default: "", null: false
    t.integer "skq_universityboard", default: 0, null: false
    t.integer "skq_degreedip", default: 0, null: false
    t.string "skq_passingyear", limit: 30, default: "", null: false
    t.string "skq_duration", limit: 15, default: "0", null: false
    t.float "skq_percenatge", limit: 53, default: 0.0, null: false
    t.string "skq_attach", limit: 60, default: "", null: false
    t.string "skq_revisedcode", limit: 50, default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mst_sewadar_kycs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "sk_compcode", limit: 30, default: "", null: false
    t.string "sk_sewcode", limit: 30, null: false
    t.string "sk_adhar", limit: 60, default: "", null: false
    t.string "sk_adharno", limit: 30, default: "", null: false
    t.string "sk_pan", limit: 60, default: "", null: false
    t.string "sk_panno", limit: 30, default: "", null: false
    t.string "sk_drivelicence", limit: 80, default: "", null: false
    t.string "sk_dlnos", limit: 40, default: "", null: false
    t.string "sk_otherdoc", limit: 60, default: "", null: false
    t.string "sk_otherdocno", limit: 60, default: "", null: false
    t.string "sk_otherdoc2", limit: 60, default: "", null: false
    t.string "sk_otherdocno2", limit: 60, default: "", null: false
    t.string "sk_prevemployeeid", limit: 30, default: "", null: false
    t.string "sk_language", limit: 60, default: "", null: false
    t.string "sk_internwork", limit: 1, default: "N", null: false
    t.string "sk_category", limit: 1, default: "N", null: false
    t.string "sk_physicalissue", limit: 1, default: "N", null: false
    t.string "sk_revisedcode", limit: 50, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sk_sewcode"], name: "sk_sewcode", unique: true
  end

  create_table "mst_sewadar_office_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "so_compcode", limit: 30, null: false
    t.string "so_sewcode", limit: 30, null: false
    t.string "so_deprtcode", limit: 30, default: "", null: false
    t.string "so_respcode", limit: 30, default: "", null: false
    t.string "so_qualifcode", limit: 30, default: "", null: false
    t.string "so_desigcode", limit: 30, default: "", null: false
    t.date "so_joiningdate", null: false
    t.date "so_regularizationdate", null: false
    t.date "so_superannuationdate", null: false
    t.date "so_leavingdate", null: false
    t.date "so_fullfinaldate", null: false
    t.string "so_leavingreason", limit: 80, default: "", null: false
    t.string "so_licgroup", limit: 1, default: "N", null: false
    t.string "so_healthinsurance", limit: 1, default: "N", null: false
    t.string "so_blessedbrahma", limit: 1, default: "N", null: false
    t.date "sp_gyandate", null: false
    t.float "so_basic", limit: 53, default: 0.0, null: false
    t.float "so_hra", limit: 53, default: 0.0, null: false
    t.float "so_conveyance", limit: 53, default: 0.0, null: false
    t.float "so_totalgross", limit: 53, default: 0.0, null: false
    t.string "so_pf", limit: 1, default: "N", null: false
    t.string "so_pfno", limit: 50, default: "", null: false
    t.string "so_uan", limit: 50, default: "", null: false
    t.string "so_extrapf", limit: 15, default: "", null: false
    t.date "so_settmentdate", null: false
    t.string "so_esi", limit: 1, default: "N", null: false
    t.string "so_esino", limit: 50, default: "", null: false
    t.string "so_dispensary", limit: 50, default: "", null: false
    t.string "so_ot", limit: 1, default: "N", null: false
    t.string "so_department", limit: 30, default: "", null: false
    t.string "so_subdepartment", limit: 30, default: "", null: false
    t.integer "so_location", default: 0, null: false
    t.integer "so_sublocation", default: 0, null: false
    t.string "so_zone", limit: 60, default: "", null: false
    t.string "so_branch", limit: 120, default: "", null: false
    t.string "so_oldsewdar", limit: 30, default: "", null: false
    t.string "so_biomatriccard", limit: 60, default: "", null: false
    t.float "so_healthslab", limit: 53, default: 0.0, null: false
    t.string "so_revisedcode", limit: 50, default: "", null: false
    t.text "so_innote_hr", limit: 4294967295, null: false
    t.text "so_outnote_sewdar", limit: 4294967295, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["so_sewcode"], name: "so_sewcode", unique: true
  end

  create_table "mst_sewadar_personal_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "sp_compcode", limit: 30, null: false
    t.string "sp_sewcode", limit: 30, null: false
    t.string "sp_perma_houseaddress", limit: 500, default: "", null: false
    t.string "sp_perma_distcity", limit: 11, default: "", null: false
    t.string "sp_perma_state", limit: 11, default: "", null: false
    t.string "sp_perma_pincode", limit: 15, default: "", null: false
    t.string "sp_pres_residenttype", limit: 60, default: "", null: false
    t.string "sp_pres_houseaddress", limit: 500, default: "", null: false
    t.string "sp_pres_distcity", limit: 11, default: "", null: false
    t.string "sp_pres_state", limit: 11, default: "", null: false
    t.string "sp_pres_pincode", limit: 15, default: "", null: false
    t.string "sp_mobileno", limit: 12, default: "", null: false
    t.string "sp_officemobno", limit: 12, default: "", null: false
    t.string "sp_landlineno", limit: 15, default: "", null: false
    t.string "sp_personal_email", limit: 80, default: "", null: false
    t.string "sp_officialmail", limit: 80, default: "", null: false
    t.string "sp_emergency_name", limit: 80, default: "", null: false
    t.string "sp_emergency_relation", limit: 80, default: "", null: false
    t.string "sp_emergency_mobno", limit: 12, default: "", null: false
    t.string "sp_mandalcode", limit: 15, default: "", null: false
    t.string "sp_revisedcode", limit: 50, default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["sp_sewcode"], name: "sp_sewcode", unique: true
  end

  create_table "mst_sewadar_work_experiences", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "swe_compcode", limit: 30, null: false
    t.string "swe_sewcode", limit: 30, default: "", null: false
    t.string "swe_employer", limit: 60, default: "", null: false
    t.string "swe_designation", limit: 60, default: "", null: false
    t.string "swe_responsiblity", limit: 200, default: "", null: false
    t.string "swe_from", limit: 30, default: "", null: false
    t.string "swe_to", limit: 30, default: "", null: false
    t.string "swe_reasonleaving", limit: 200, default: "", null: false
    t.string "swe_retirebenfit", limit: 1, default: "N", null: false
    t.string "swe_gettingpension", limit: 1, default: "N", null: false
    t.string "swe_medicalfacilities", limit: 1, default: "N", null: false
    t.string "swe_revisedcode", limit: 50, default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mst_sewadars", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "sw_compcode", limit: 30, null: false
    t.string "sw_sewcode", limit: 30, null: false
    t.string "sw_sewadar_name", limit: 60, null: false
    t.string "sw_sewadar_prefix", limit: 10, default: "", null: false
    t.string "sw_father_name", limit: 60, default: "", null: false
    t.string "sw_father_prefix", limit: 10, default: "", null: false
    t.date "sw_date_of_birth", null: false
    t.string "sw_maritalstatus", limit: 1, default: "N", null: false
    t.string "sw_gender", limit: 1, default: "", null: false
    t.string "sw_branchtype", limit: 30, default: "", null: false
    t.string "sw_catgeory", limit: 60, null: false
    t.string "sw_catcode", limit: 30, null: false
    t.string "sw_desigcode", limit: 30, default: "", null: false
    t.string "sw_depcode", limit: 30, default: "", null: false
    t.string "sw_qualfcode", limit: 30, default: "", null: false
    t.date "sw_joiningdate", null: false
    t.date "sw_leavingdate", null: false
    t.string "sw_image", limit: 80, default: "", null: false
    t.string "sw_location", limit: 30, default: "", null: false
    t.string "sw_mobile", limit: 12, default: "", null: false
    t.string "sw_email", limit: 80, default: "", null: false
    t.string "sw_motherprefix", limit: 20, default: "", null: false
    t.string "sw_mothername", limit: 80, default: "", null: false
    t.string "sw_husbprefix", limit: 30, default: "", null: false
    t.string "sw_husbandname", limit: 80, default: "", null: false
    t.string "sw_oldsewdarcode", limit: 50, default: "", null: false
    t.float "sw_outstandingamt", limit: 53, default: 0.0, null: false
    t.float "sw_loanamount", limit: 53, default: 0.0, null: false
    t.string "sw_status", limit: 1, default: "N", null: false
    t.string "sw_revisedcode", limit: 50, default: "", null: false
    t.string "sw_revisedoldcode", limit: 50, default: "", null: false
    t.string "sw_sewadar_aadhaar", limit: 60, default: "", null: false
    t.string "sw_isaccommodation", limit: 1, default: "N", null: false
    t.integer "sw_accomodationtype", default: 0, null: false
    t.string "sw_iselectricconsump", limit: 1, default: "N", null: false
    t.string "sw_meterno", limit: 50, default: "", null: false
    t.string "sw_electricexemption", limit: 1, default: "N", null: false
    t.string "sw_accomodexemption", limit: 1, default: "N", null: false
    t.string "sw_shiftcode", limit: 4, default: "", null: false
    t.string "sw_prevlwm", limit: 25, default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["id"], name: "id", unique: true
    t.index ["id"], name: "id_2"
    t.index ["sw_compcode"], name: "sw_compcode"
    t.index ["sw_sewcode"], name: "sw_sewcode"
  end

  create_table "mst_sewdar_kyc_family_details", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "skf_compcode", limit: 30, null: false
    t.string "skf_sewcode", limit: 30, null: false
    t.string "skf_dependent", limit: 60, default: "", null: false
    t.string "skf_relation", limit: 60, default: "", null: false
    t.date "skf_datebirth", null: false
    t.string "skf_address", null: false
    t.string "skf_occupation", limit: 60, default: "", null: false
    t.string "skf_nominee", limit: 1, default: "N", null: false
    t.float "skf_percentage", limit: 53, default: 0.0, null: false
    t.string "skf_nomineebank", limit: 200, default: "", null: false
    t.string "skf_optedpolicy", limit: 1, default: "N", null: false
    t.string "skf_pannumber", limit: 15, default: "", null: false
    t.string "skf_attachment", limit: 80, default: "", null: false
    t.string "skf_gender", limit: 10, default: "", null: false
    t.string "skf_revisedcode", limit: 50, default: "", null: false
    t.string "skf_married_status", limit: 1, default: "", null: false
    t.string "skf_working_withsnm", limit: 1, default: "", null: false
    t.string "skf_working_sewacode", limit: 50, default: "", null: false
    t.string "skf_family_dependent", limit: 1, default: "", null: false
    t.string "skf_otherrelation", limit: 60, default: "", null: false
    t.integer "skf_university", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mst_shifts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "attend_compcode", limit: 30, null: false
    t.string "attend_shiftcode", limit: 30, null: false
    t.string "attend_nightshift", limit: 1, default: "B", null: false
    t.string "attend_shfintime", limit: 10, default: "00:00:00", null: false
    t.string "attend_shfout", limit: 10, default: "00:00:00", null: false
    t.string "attend_shfhrs", limit: 10, default: "00:00:00", null: false
    t.string "attend_outtime", limit: 10, default: "00:00:00", null: false
    t.string "attend_intime", limit: 10, default: "00:00:00", null: false
    t.string "attend_runworking", limit: 10, default: "00:00:00", null: false
    t.string "attend_starttime", limit: 10, default: "00:00:00", null: false
    t.string "attend_endtime", limit: 10, default: "00:00:00", null: false
    t.string "attend_endhours", limit: 10, default: "00:00:00", null: false
    t.float "attend_absentforworking", limit: 24, default: 0.0, null: false
    t.float "attend_presentforwork", limit: 24, default: 0.0, null: false
    t.float "attend_othhrsallowed", limit: 24, default: 0.0, null: false
    t.integer "attend_otdeductafterhrs", limit: 1, default: 0, null: false
    t.float "attend_otdeducthrs", limit: 24, default: 0.0, null: false
    t.string "attend_ist", limit: 5, default: "", null: false
    t.string "attend_2nd", limit: 5, default: "", null: false
    t.string "attend_sat1st", limit: 1, default: "N", null: false
    t.string "attend_sat2nd", limit: 1, default: "N", null: false
    t.string "attend_sat3rd", limit: 1, default: "N", null: false
    t.string "attend_sat4th", limit: 1, default: "N", null: false
    t.string "attend_sat5th", limit: 1, default: "N", null: false
    t.string "attend_sathaf1st", limit: 1, default: "N", null: false
    t.string "attend_sathaf2nd", limit: 1, default: "N", null: false
    t.string "attend_sathaf3rd", limit: 1, default: "N", null: false
    t.string "attend_sathaf4th", limit: 1, default: "N", null: false
    t.string "attend_sathaf5th", limit: 1, default: "N", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mst_states", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "sts_compcode", limit: 30, null: false
    t.string "sts_code", limit: 10, null: false
    t.string "sts_description", limit: 60, null: false
    t.integer "sts_welfare", default: 0, null: false
    t.integer "sts_welfare_employer", default: 0, null: false
    t.string "sts_stategstcode", limit: 10, default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mst_sub_locations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "sl_compcode", limit: 30, null: false
    t.integer "sl_locid", null: false
    t.string "sl_type", limit: 20, default: "", null: false
    t.string "sl_description", limit: 150, default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mst_subscription_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci" do |t|
    t.string "subtyp_name", limit: 60, null: false
    t.string "subtyp_compcode", limit: 30, null: false
    t.string "subtyp_code", limit: 30, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", limit: 1, default: "Y"
  end

  create_table "mst_units", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "un_compcode", limit: 20, null: false
    t.string "un_sewacode", limit: 80, null: false
    t.float "un_amount", limit: 53, default: 0.0, null: false
    t.integer "um_type", default: 0, null: false
    t.string "um_status", limit: 1, default: "", null: false
    t.float "un_ob", limit: 53, default: 0.0, null: false
    t.float "un_cb", limit: 53, default: 0.0, null: false
    t.float "un_credit", limit: 53, default: 0.0, null: false
    t.string "un_leavetype", limit: 5, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mst_universities", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "un_compcode", limit: 30, null: false
    t.string "un_description", limit: 80, null: false
    t.string "un_qltype", limit: 600, default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mst_zone_districts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "zd_compcode", limit: 30, null: false
    t.string "zd_zonecode", limit: 30, null: false
    t.string "zd_distcode", limit: 30, null: false
    t.string "zd_name", limit: 90, null: false
    t.string "zd_othcode", limit: 30, default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mst_zones", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "zn_compcode", limit: 30, null: false
    t.string "zn_zonecode", limit: 30, null: false
    t.string "zn_number", limit: 30, null: false
    t.string "zn_name", limit: 80, null: false
    t.string "zn_incharge", limit: 100, default: "", null: false
    t.string "zn_inchmobile", limit: 100, default: "", null: false
    t.string "zn_addcontact", limit: 100, default: "", null: false
    t.string "zn_landlineno", limit: 100, default: "", null: false
    t.string "zn_inchargaddress", default: "", null: false
    t.string "zn_inchargesnm_email", limit: 80, default: "", null: false
    t.string "zn_zone_email", limit: 100, default: "", null: false
    t.string "zn_zoneoffice", limit: 30, default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "sessions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "subscription_logs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci" do |t|
    t.string "sl_title", limit: 200, null: false
    t.string "sl_compcode", limit: 30, null: false
    t.string "sl_membercode", limit: 30, null: false
    t.string "sl_subcode", limit: 30, null: false
    t.string "sl_description", limit: 500, null: false
    t.string "sl_type", limit: 100, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscriptions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci" do |t|
    t.string "sub_code", limit: 30, null: false
    t.string "sub_name", limit: 60, null: false
    t.string "sub_compcode", limit: 30, null: false
    t.string "sub_amount", limit: 30, null: false
    t.string "sub_amountrcv", limit: 30, null: false
    t.string "sub_bankname", limit: 30, null: false
    t.string "sub_branch", limit: 30, null: false
    t.string "sub_currency", limit: 30, null: false
    t.string "sub_dispatchmode", limit: 30, null: false
    t.string "sub_dispatchtype", limit: 30, null: false
    t.string "sub_dispatchto", limit: 30, null: false
    t.date "sub_docdate", null: false
    t.string "sub_docnum", limit: 30, null: false
    t.date "sub_enddate", null: false
    t.string "sub_inramount", limit: 30, null: false
    t.string "sub_magazine", limit: 30, null: false
    t.string "sub_member", limit: 30, null: false
    t.string "sub_paymentmode", limit: 30, null: false
    t.string "sub_quantity", limit: 30, null: false
    t.string "sub_reason_change", limit: 200, null: false
    t.date "sub_receiptdate", null: false
    t.string "sub_receiptno", limit: 30, null: false
    t.string "sub_remarks", limit: 200, null: false
    t.string "sub_roe", limit: 30, null: false
    t.date "sub_startdate", null: false
    t.string "sub_status", limit: 1, default: "Y", null: false
    t.string "sub_subtyp", limit: 30, null: false
  end

  create_table "trn_advance_adjustments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "aa_compcode", limit: 30, null: false
    t.string "aa_requestno", limit: 50, default: "", null: false
    t.string "aa_department", limit: 30, default: "", null: false
    t.string "aa_swadarcode", limit: 50, default: "", null: false
    t.float "aa_currentoustanding", limit: 53, default: 0.0, null: false
    t.float "aa_adjustmentamt", limit: 53, default: 0.0, null: false
    t.date "aa_adjustmentdate", null: false
    t.string "aa_attachemnt", limit: 80, default: "", null: false
    t.string "aa_remark", limit: 100, default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "trn_advance_loans", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "al_compcode", limit: 30, null: false
    t.string "al_requestno", limit: 30, null: false
    t.string "al_depcode", limit: 30, null: false
    t.string "al_sewadarcode", limit: 30, null: false
    t.date "al_requestdate", null: false
    t.string "al_requesttype", limit: 30, default: "", null: false
    t.float "al_advanceamt", limit: 53, default: 0.0, null: false
    t.float "al_loanamount", limit: 53, default: 0.0, null: false
    t.float "al_installpermonth", limit: 53, default: 0.0, null: false
    t.string "al_remark", limit: 300, default: "", null: false
    t.string "al_hrremark", limit: 120, default: "", null: false
    t.string "al_approvestatus", limit: 1, default: "N", null: false
    t.date "al_apprvdated", null: false
    t.string "al_broucherno", limit: 50, default: "", null: false
    t.date "al_boucherdate", null: false
    t.float "al_balances", limit: 53, default: 0.0, null: false
    t.string "al_hod_status", limit: 1, default: "N", null: false
    t.string "al_hod_remark", limit: 120, default: "", null: false
    t.date "al_hoddated", null: false
    t.integer "al_approvedby", default: 0, null: false
    t.string "al_openingdata", limit: 1, default: "", null: false
    t.string "al_purpose", default: "", null: false
    t.string "al_attachfirst", limit: 80, default: "", null: false
    t.string "al_attchsec", limit: 80, default: "", null: false
    t.string "al_attachthird", limit: 80, default: "", null: false
    t.string "al_atttitlefirst", limit: 80, default: "", null: false
    t.string "al_attachtilesec", limit: 80, default: "", null: false
    t.string "al_attachtitlethird", limit: 80, default: "", null: false
    t.string "al_guarantorattach", limit: 80, default: "", null: false
    t.string "al_guarantortitle", limit: 80, default: "", null: false
    t.string "al_guarantordept", limit: 30, default: "", null: false
    t.string "al_guarantorname", limit: 30, default: "", null: false
    t.string "al_exmpaccomodation", limit: 1, default: "N", null: false
    t.string "al_exmptotalsewa", limit: 1, default: "N", null: false
    t.string "al_exmpreamrk", limit: 80, default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "trn_announcements", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "ans_compcode", limit: 30, null: false
    t.string "ans_postedby", limit: 60, null: false
    t.string "ans_posteddashboard", limit: 60, default: "", null: false
    t.date "ans_postingdate", null: false
    t.string "ans_postingtime", limit: 20, default: ""
    t.text "ans_announcment", limit: 4294967295, null: false, collation: "utf8mb3_bin"
    t.date "ans_publishdate", null: false
    t.string "ans_publishtime", limit: 20, default: "", null: false
    t.string "ans_status", limit: 1, default: "N", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "trn_apply_education_aids", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "aea_compcode", limit: 30, null: false
    t.string "aea_requestno", limit: 30, null: false
    t.date "aea_requestdate", null: false
    t.string "aea_departcode", limit: 50, null: false
    t.string "aea_sewadarcode", limit: 50, null: false
    t.string "aea_applyfor", limit: 100, default: "", null: false
    t.integer "aea_dependent", default: 0, null: false
    t.string "ama_attachfirst", limit: 80, default: "", null: false
    t.string "aea_attachsecond", limit: 80, default: "", null: false
    t.string "aea_attachthird", limit: 80, default: "", null: false
    t.string "aea_titlefirst", limit: 80, default: "", null: false
    t.string "aea_tiitlesec", limit: 80, default: "", null: false
    t.string "aea_titlethird", limit: 80, default: "", null: false
    t.integer "aea_forclass", default: 0, null: false
    t.string "aea_status", limit: 1, default: "N", null: false
    t.integer "aea_approvedby", default: 0, null: false
    t.date "aea_approvedated", null: false
    t.string "aea_localtime", limit: 15, default: "", null: false
    t.float "aea_amount", limit: 53, default: 0.0, null: false
    t.string "aea_remark", default: "", null: false
    t.string "aea_voucherno", limit: 50, default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "trn_apply_leaves", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "trn_apply_marriage_aids", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "ama_compcode", limit: 30, null: false
    t.string "ama_requestno", limit: 30, null: false
    t.date "ama_requestdate", null: false
    t.string "ama_departcode", limit: 50, null: false
    t.string "ama_sewadarcode", limit: 50, null: false
    t.string "ama_applyfor", limit: 100, default: "", null: false
    t.integer "ama_dependent", default: 0, null: false
    t.string "ama_attachfirst", limit: 80, default: "", null: false
    t.string "ama_attachsecond", limit: 80, default: "", null: false
    t.string "ama_attachthird", limit: 80, default: "", null: false
    t.string "ama_titlefirst", limit: 80, default: "", null: false
    t.string "ama_tiitlesec", limit: 80, default: "", null: false
    t.string "ama_titlethird", limit: 80, default: "", null: false
    t.string "ama_status", limit: 1, default: "N", null: false
    t.integer "ama_approvedby", default: 0, null: false
    t.date "ama_approvedated", null: false
    t.string "ama_localtime", limit: 15, default: "", null: false
    t.float "ama_amount", limit: 53, default: 0.0, null: false
    t.string "ama_remark", default: ""
    t.string "ama_voucherno", limit: 50, default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "trn_attendance_lists", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "al_compcode", limit: 30, null: false
    t.string "al_empcode", limit: 50, null: false
    t.string "al_department", limit: 60, default: "", null: false
    t.string "al_location", limit: 60, default: "", null: false
    t.date "al_trandate", null: false
    t.string "al_entryreq", limit: 2, default: "2", null: false
    t.string "al_entrymade", limit: 2, default: "2", null: false
    t.string "al_shift", limit: 3, default: "", null: false
    t.string "al_catid", limit: 20, default: "", null: false
    t.string "al_arrtime", limit: 10, default: "", null: false
    t.string "al_latehrs", limit: 10, default: "", null: false
    t.string "all_deptime", limit: 10, default: "", null: false
    t.string "al_earlhrs", limit: 10, default: "", null: false
    t.string "al_workhrs", limit: 10, default: "", null: false
    t.string "al_overtime", limit: 10, default: "", null: false
    t.string "al_present", limit: 5, default: "0", null: false
    t.string "al_absent", limit: 5, default: "0", null: false
    t.string "al_presabsent", limit: 3, default: "", null: false
    t.float "al_paidleave", limit: 24, default: 0.0, null: false
    t.float "al_unpaidleave", limit: 24, default: 0.0, null: false
    t.string "al_manualpunch", limit: 30, default: "", null: false
    t.string "al_nightshift", limit: 2, default: "N", null: false
    t.string "al_departid", limit: 60, default: "", null: false
    t.string "al_misspunch", limit: 2, default: "", null: false
    t.string "al_userimage", limit: 80, default: "", null: false
    t.string "al_latepelanty", limit: 30, default: "", null: false
    t.string "al_leavecode", limit: 30, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["al_compcode"], name: "al_compcode"
    t.index ["al_department"], name: "al_department"
    t.index ["al_empcode"], name: "al_empcode"
    t.index ["al_trandate"], name: "al_trandate"
  end

  create_table "trn_bakshish_transactions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "bt_compcode", limit: 30, null: false
    t.string "bt_sewacode", limit: 30, default: "", null: false
    t.string "bt_department", limit: 50, default: "", null: false
    t.string "bt_departname", limit: 120, default: "", null: false
    t.string "bt_designation", limit: 50, default: "", null: false
    t.string "bt_designname", limit: 120, default: "", null: false
    t.string "bt_category", limit: 50, default: "", null: false
    t.float "bt_payamount", limit: 53, default: 0.0, null: false
    t.date "bt_date", null: false
    t.string "bt_year", limit: 10, default: "", null: false
    t.string "bt_total_sewa", limit: 120, default: "", null: false
    t.string "bt_sewadarname", limit: 120, default: "", null: false
    t.string "bt_accountno", limit: 80, default: "", null: false
    t.string "bt_ifsccode", limit: 60, default: "", null: false
    t.string "bt_bankname", limit: 120, default: "", null: false
    t.date "bt_datejoining", null: false
    t.float "bt_ma", limit: 53, null: false
    t.string "bt_refercode", limit: 60, default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "trn_credit_leaves", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "cl_compcode", limit: 30, null: false
    t.string "cl_leavecode", limit: 30, default: "", null: false
    t.string "cl_sewacode", limit: 50, default: "", null: false
    t.float "cl_creditdays", limit: 53, default: 0.0, null: false
    t.date "cl_creditdate", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "trn_disciplines", primary_key: "dsp_id", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "dsp_compcode", limit: 30, null: false
    t.string "dsp_depcode", limit: 50, default: "", null: false
    t.string "dsp_empcode", limit: 50, null: false
    t.date "dsp_date", null: false
    t.string "dsp_rem", null: false
    t.string "dsp_reqno", limit: 30, null: false
  end

  create_table "trn_dispatch_postals", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "dps_compcode", limit: 30, null: false
    t.string "dps_entryno", limit: 50, null: false
    t.date "dps_entrydate", null: false
    t.string "dps_postedby", limit: 60, null: false
    t.string "dps_department", limit: 50, default: "", null: false
    t.string "dps_name", default: "", null: false
    t.string "dps_subject", default: "", null: false
    t.string "dps_type", limit: 20, default: "", null: false
    t.float "dps_charges", limit: 53, default: 0.0, null: false
    t.string "dps_zone", limit: 60, default: "", null: false
    t.string "dps_branch", limit: 60, default: "", null: false
    t.float "dps_stampbalance", limit: 53, default: 0.0, null: false
    t.string "dps_reamark", default: "", null: false
    t.string "dps_branchaddress", default: "", null: false
    t.string "dps_docno", limit: 55, default: "", null: false
    t.string "dps_trackingno", limit: 55, default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "trn_electric_consumptions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "ec_compcode", limit: 30, null: false
    t.string "ec_entryno", limit: 30, null: false
    t.date "ec_readingdate", null: false
    t.string "ec_department", limit: 30, default: "", null: false
    t.string "ec_sewdarcode", limit: 50, default: "", null: false
    t.string "ec_readingyear", limit: 5, default: "", null: false
    t.string "ec_readingmonth", limit: 25, default: "", null: false
    t.float "ec_lastreading", limit: 53, default: 0.0, null: false
    t.float "ec_currentreading", limit: 53, default: 0.0, null: false
    t.float "ec_totalunit", limit: 53, default: 0.0, null: false
    t.float "ec_totalamount", limit: 53, default: 0.0, null: false
    t.string "ec_reamrk", limit: 180, default: "", null: false
    t.string "ec_newmeter", limit: 1, default: "N", null: false
    t.float "ec_oldreading", limit: 53, default: 0.0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "trn_full_finals", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "ff_compcode", limit: 30, null: false
    t.string "ff_departcode", limit: 50, null: false
    t.string "ff_sewacode", limit: 50, null: false
    t.date "ff_leavingdate", null: false
    t.string "ff_leavingreason", default: "", null: false
    t.date "ff_fullandfinaldate", null: false
    t.date "ff_datejoing", null: false
    t.date "ff_datereguliazation", null: false
    t.date "ff_dob", null: false
    t.date "ff_datesupan", null: false
    t.string "ff_totalsewa", limit: 60, default: "", null: false
    t.float "ff_maintenancealw", limit: 53, default: 0.0, null: false
    t.float "ff_totaladvance", limit: 53, default: 0.0, null: false
    t.float "ff_totalel", limit: 24, default: 0.0, null: false
    t.float "ff_encashel", limit: 53, default: 0.0, null: false
    t.float "ff_exgratiatued", limit: 53, default: 0.0, null: false
    t.string "ff_vaccant", limit: 1, default: "", null: false
    t.float "ff_gratiaamount", limit: 53, default: 0.0, null: false
    t.float "ff_goldenhandshake", limit: 24, default: 0.0, null: false
    t.float "ff_goldenhandshkamt", limit: 53, default: 0.0, null: false
    t.float "ff_prevsalary", limit: 53, default: 0.0, null: false
    t.integer "ff_preparedby", default: 0, null: false
    t.float "ff_deductfirst", limit: 53, default: 0.0, null: false
    t.float "ff_deductsecond", limit: 53, default: 0.0, null: false
    t.string "ff_deductfirstrmk", limit: 60, default: "", null: false
    t.string "ff_deductsecrmk", limit: 60, default: "", null: false
    t.string "ff_totallwm", limit: 30, default: "", null: false
    t.string "ff_beforelwmtotalsewa", limit: 50, default: "", null: false
    t.string "ff_addingma", limit: 2, default: "N", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "trn_geo_locations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "gc_compcode", limit: 20, null: false
    t.string "gc_latitude", limit: 500, default: "", null: false
    t.string "gc_longitude", limit: 500, default: "", null: false
    t.string "gc_address", limit: 500, default: "", null: false
    t.string "gc_user_id", limit: 30, default: "", null: false
    t.date "gc_date", null: false
    t.time "gc_time", null: false
    t.integer "gc_customer_id", default: 0, null: false
    t.string "gc_visit_number", limit: 20, default: "", null: false
    t.string "gc_duty", limit: 3, default: "", null: false
    t.string "gc_local_time", limit: 15, null: false
    t.string "gc_userimage", limit: 60, default: "", null: false
    t.string "gc_punchtype", limit: 1, default: "N", null: false
    t.string "gc_location", limit: 40, default: "", null: false
    t.string "gc_shiftcode", limit: 4, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gc_compcode"], name: "gc_compcode"
    t.index ["gc_date"], name: "gc_date"
    t.index ["gc_user_id"], name: "gc_user_id"
  end

  create_table "trn_installments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "trns_compcode", limit: 30, null: false
    t.string "trns_depcode", limit: 50, default: "", null: false
    t.string "trns_empcode", limit: 50, null: false
    t.string "trns_rem", limit: 240, null: false
    t.string "trns_type", limit: 20, null: false
    t.float "trns_old", limit: 53, default: 0.0, null: false
    t.float "trns_change", limit: 53, default: 0.0, null: false
    t.string "trns_mon", limit: 20, default: ""
    t.string "trns_year", limit: 20, default: ""
    t.string "trns_attachemnet", limit: 80, default: "", null: false
    t.date "trns_dated", null: false
    t.string "trns_status", limit: 1, default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "trn_leave_balances", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "lb_compcode", limit: 30, null: false
    t.string "lb_empcode", limit: 30, null: false
    t.string "lb_leavecode", limit: 15, null: false
    t.float "lb_openbal", limit: 53, default: 0.0, null: false
    t.float "lb_closingbal", limit: 53, default: 0.0, null: false
    t.float "lb_cfbalance", limit: 53, default: 0.0, null: false
    t.integer "lb_year", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trn_leaves", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "ls_compcode", limit: 20, null: false
    t.float "ls_nodays", limit: 24, default: 0.0, null: false
    t.string "ls_empcode", limit: 30, null: false
    t.string "ls_depcode", limit: 50, default: "", null: false
    t.date "ls_fromdate", null: false
    t.date "ls_todate", null: false
    t.string "ls_leave_code", limit: 10, null: false
    t.integer "ls_remainleave", default: 0, null: false
    t.string "ls_leavereson", default: "", null: false
    t.string "ls_number", limit: 30, default: "", null: false
    t.string "ls_approved_by", limit: 50, default: "", null: false
    t.date "ls_approve_date", null: false
    t.string "ls_status", limit: 1, default: "P", null: false
    t.string "ls_avail", limit: 1, default: "", null: false
    t.string "ls_period", limit: 1, default: "", null: false
    t.string "ls_category", limit: 30, default: "", null: false
    t.string "ls_requestcancel", limit: 1, default: "N", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ls_compcode"], name: "ls_compcode"
    t.index ["ls_empcode"], name: "ls_empcode"
    t.index ["ls_fromdate"], name: "ls_fromdate"
    t.index ["ls_status"], name: "ls_status"
    t.index ["ls_todate"], name: "ls_todate"
  end

  create_table "trn_manual_punches", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "mp_compcode", limit: 20, null: false
    t.string "mp_empcode", limit: 20, null: false
    t.string "mp_card_number", limit: 20, null: false
    t.date "mp_date", null: false
    t.time "mp_time", null: false
    t.integer "mp_punch", limit: 1, default: 0, null: false
    t.string "mp_flag", limit: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trn_pay_monthlies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "pm_compcode", limit: 30, null: false
    t.string "pm_sewacode", limit: 50, null: false
    t.string "pm_department", limit: 50, default: "", null: false
    t.string "pm_category", limit: 50, default: "", null: false
    t.string "pm_descode", limit: 50, default: "", null: false
    t.string "pm_bankname", limit: 120, default: "", null: false
    t.string "pm_bankaccountno", limit: 80, default: "", null: false
    t.string "pm_type", limit: 50, default: "", null: false
    t.integer "pm_paymonth", default: 0, null: false
    t.integer "pm_payyear", default: 0, null: false
    t.integer "pm_monthday", default: 0, null: false
    t.float "pm_paidleave", limit: 53, default: 0.0, null: false
    t.float "pm_unpaidleave", limit: 53, default: 0.0, null: false
    t.float "pm_absent", limit: 53, default: 0.0, null: false
    t.float "pm_wo", limit: 53, default: 0.0, null: false
    t.float "pm_hl", limit: 53, default: 0.0, null: false
    t.float "pm_workingday", limit: 53, default: 0.0, null: false
    t.float "pm_paydays", limit: 53, default: 0.0, null: false
    t.float "pm_basic", limit: 53, default: 0.0, null: false
    t.float "pm_hra", limit: 53, default: 0.0, null: false
    t.float "pm_convenience", limit: 53, default: 0.0, null: false
    t.float "pm_total", limit: 53, default: 0.0, null: false
    t.float "pm_actbasic", limit: 53, default: 0.0, null: false
    t.float "pm_acthra", limit: 53, default: 0.0, null: false
    t.float "pm_actconv", limit: 53, default: 0.0, null: false
    t.float "pm_acttotal", limit: 53, default: 0.0, null: false
    t.float "pm_arear", limit: 53, default: 0.0, null: false
    t.float "pm_fixarear", limit: 53, default: 0.0, null: false
    t.float "pm_areardays", limit: 53, default: 0.0, null: false
    t.integer "pm_areaprvmonths", default: 0, null: false
    t.integer "pm_areaprvyears", default: 0, null: false
    t.float "pm_ded_repaidadvance", limit: 53, default: 0.0, null: false
    t.float "pm_ded_repaidloan", limit: 53, default: 0.0, null: false
    t.float "pm_ded_electricunit", limit: 53, default: 0.0, null: false
    t.float "pm_ded_electricamount", limit: 53, default: 0.0, null: false
    t.integer "pm_dedaccomodatype", default: 0, null: false
    t.string "pm_dedaccomodationno", limit: 30, default: "0", null: false
    t.float "pm_dedaccomodatamount", limit: 53, default: 0.0, null: false
    t.float "pm_licemployer", limit: 53, default: 0.0, null: false
    t.float "pm_ded_licemployee", limit: 53, default: 0.0, null: false
    t.float "pm_ded_healthslab", limit: 53, default: 0.0, null: false
    t.float "pm_ded_healthmandalpay", limit: 53, default: 0.0, null: false
    t.float "pm_ded_healthsewdarpay", limit: 53, default: 0.0, null: false
    t.float "pm_ded_incometaxpercent", limit: 53, default: 0.0, null: false
    t.float "pm_incometaxamount", limit: 53, default: 0.0, null: false
    t.float "pm_totaldeduction", limit: 53, default: 0.0, null: false
    t.float "pm_totalallowance", limit: 53, default: 0.0, null: false
    t.float "pm_totaltds", limit: 53, default: 0.0, null: false
    t.float "pm_netpay", limit: 53, default: 0.0, null: false
    t.string "pm_financialyear", limit: 30, default: "", null: false
    t.float "pm_allowancefirst", limit: 53, default: 0.0, null: false
    t.string "pm_allowanremarkfirst", limit: 60, default: "", null: false
    t.float "pm_allowancesecond", limit: 53, default: 0.0, null: false
    t.string "pm_allowanceremksecond", limit: 60, default: ""
    t.float "pm_dedfirst", limit: 53, default: 0.0, null: false
    t.string "pm_dedremarkfirst", limit: 60, default: "", null: false
    t.float "pm_dedsecond", limit: 53, default: 0.0, null: false
    t.string "pm_dedremarksecond", limit: 60, default: "", null: false
    t.float "pm_totalel", limit: 53, default: 0.0, null: false
    t.float "pm_elencash", limit: 53, default: 0.0, null: false
    t.string "pm_isposted", limit: 1, default: "N", null: false
    t.string "pm_hold", limit: 1, default: "N", null: false
    t.string "pm_arearremarks", limit: 80, default: "", null: false
    t.float "pm_sewadar_n_spouse", limit: 24, default: 0.0, null: false
    t.float "pm_healthdependent", limit: 53, default: 0.0, null: false
    t.float "pm_healthparent", limit: 53, default: 0.0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "trn_postal_receives", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "prs_compcode", limit: 30, null: false
    t.string "prs_entryno", limit: 50, null: false
    t.date "prs_entrydate", null: false
    t.string "prs_postedby", limit: 60, null: false
    t.string "prs_department", limit: 50, default: "", null: false
    t.string "prs_name", limit: 100, default: "", null: false
    t.string "prs_subject", limit: 120, default: "", null: false
    t.string "prs_type", limit: 20, default: "", null: false
    t.float "prs_charges", limit: 53, default: 0.0, null: false
    t.string "prs_zone", limit: 60, default: "", null: false
    t.string "prs_branch", limit: 60, default: "", null: false
    t.float "prs_stampbalance", limit: 53, default: 0.0, null: false
    t.string "prs_reamark", default: "", null: false
    t.string "prs_branchaddress", default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "trn_prawn_tables", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "dt_compcode", limit: 20, null: false
    t.string "dt_billnumber", limit: 15, null: false
    t.string "dt_itemcode", limit: 15, null: false
    t.string "dt_itemname", limit: 60, null: false
    t.string "dt_serialno", limit: 1, null: false
    t.string "dt_uom", limit: 10, null: false
    t.string "dt_hsncode", limit: 25, null: false
    t.integer "dt_quantity", null: false
    t.decimal "dt_rate", precision: 8, scale: 2, null: false
    t.decimal "dt_values", precision: 15, scale: 2, null: false
    t.decimal "dt_discount", precision: 8, scale: 2, null: false
    t.decimal "dt_discountamount", precision: 10, scale: 2, null: false
    t.float "dt_igst", limit: 24, default: 0.0, null: false
    t.decimal "dt_igstamount", precision: 10, scale: 2, null: false
    t.float "dt_cgst", limit: 24, null: false
    t.decimal "dt_cgstamount", precision: 10, scale: 2, null: false
    t.float "dt_sgst", limit: 24, null: false
    t.decimal "dt_sgstamount", precision: 10, scale: 2, null: false
    t.decimal "dt_netamount", precision: 15, scale: 2, null: false
    t.string "dt_sale_type", limit: 2, default: "", null: false
    t.string "hd_billdate", limit: 10, null: false
    t.string "cs_customername", limit: 4, null: false
    t.string "cs_gstnumber", limit: 11, null: false
    t.string "hd_paymentmode", limit: 5, null: false
    t.string "debitsamt", limit: 5, null: false
    t.string "creditsamt", limit: 5, null: false
    t.string "hd_remark", limit: 5, null: false
    t.integer "balanceamt", null: false
    t.string "customsaletype", limit: 3, null: false
    t.string "cs_mobilenumber", limit: 3, null: false
    t.string "cs_emailaddress", limit: 3, null: false
    t.string "cs_telephonenumbers", limit: 3, null: false
    t.string "topensamt", limit: 3, null: false
    t.integer "hd_customer_id", null: false
    t.string "dt_factor", limit: 5, default: "0", null: false
    t.decimal "dt_debit", precision: 4, scale: 2, default: "0.0", null: false
    t.decimal "dt_factor_value", precision: 18, scale: 2, default: "0.0", null: false
    t.decimal "dt_taxdebit_value", precision: 18, scale: 2, default: "0.0", null: false
    t.integer "dt_godaam_id", default: 0, null: false
    t.string "asn_field1", limit: 1, null: false
    t.string "asn_field2", limit: 1, null: false
    t.string "asn_field3", limit: 1, null: false
    t.string "asn_field4", limit: 1, null: false
    t.string "asn_field5", limit: 1, null: false
    t.string "asn_field6", limit: 1, null: false
    t.string "asn_field7", limit: 1, null: false
    t.string "asn_field8", limit: 1, null: false
    t.string "dt_date", limit: 1, null: false
    t.string "dt_amounts", limit: 1, null: false
    t.integer "dt_netprice", null: false
    t.string "dt_ref_code", limit: 1, null: false
    t.string "godaamname", limit: 1, null: false
    t.string "dt_material", limit: 1, default: "", null: false
    t.string "dt_color", limit: 1, default: "", null: false
    t.string "dt_position", limit: 1, null: false
    t.string "pdimage", limit: 1, null: false
    t.string "dt_remark", limit: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trn_process_monthly_advances", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "pma_compcode", limit: 30, null: false
    t.string "pma_sewacode", limit: 60, null: false
    t.string "pma_requestno", limit: 30, null: false
    t.string "pma_month", limit: 30, default: "", null: false
    t.integer "pma_year", default: 0, null: false
    t.string "pma_type", limit: 80, default: "", null: false
    t.float "pma_installment", limit: 53, default: 0.0, null: false
    t.string "pma_remarks", limit: 30, default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "trn_raise_tickets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "rt_compcode", limit: 30, null: false
    t.string "rt_ticketno", limit: 30, null: false
    t.date "rt_ticketdate", null: false
    t.string "rt_tickettime", limit: 15, default: "", null: false
    t.string "rt_sewadar", limit: 50, default: "", null: false
    t.string "rt_department", limit: 50, default: "", null: false
    t.string "rt_assignedsewacode", limit: 30, default: "", null: false
    t.string "rt_issueraisedby", limit: 50, default: "", null: false
    t.string "rt_priorty", limit: 5, default: "", null: false
    t.string "rt_queryissue", default: "", null: false
    t.string "rt_status", limit: 1, default: "", null: false
    t.string "rt_attachment", limit: 80, default: "", null: false
    t.string "rt_titles", limit: 120, default: "", null: false
    t.string "rt_supporttype", limit: 130, default: "", null: false
    t.string "rt_raiseddep", limit: 50, default: "", null: false
    t.text "rt_resolveremark", limit: 4294967295, null: false
    t.text "rt_feeback", limit: 4294967295, null: false
    t.float "rt_rating", limit: 24, default: 0.0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "trn_request_co_ods", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "ls_compcode", limit: 20, null: false
    t.float "ls_nodays", limit: 24, default: 0.0, null: false
    t.string "ls_empcode", limit: 30, null: false
    t.string "ls_depcode", limit: 50, default: "", null: false
    t.date "ls_fromdate", null: false
    t.date "ls_todate", null: false
    t.string "ls_leave_code", limit: 10, null: false
    t.integer "ls_remainleave", default: 0, null: false
    t.string "ls_leavereson", default: "", null: false
    t.string "ls_number", limit: 30, default: "", null: false
    t.string "ls_approved_by", limit: 50, default: "", null: false
    t.string "ls_status", limit: 1, default: "P", null: false
    t.string "ls_avail", limit: 1, default: "", null: false
    t.string "ls_period", limit: 1, default: "", null: false
    t.string "ls_category", limit: 30, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trn_temp_advance_ledgers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.float "adamounts", limit: 53, default: 0.0, null: false
    t.string "types", limit: 60, default: "", null: false
    t.integer "reqdated", default: 0, null: false
    t.integer "requestyear", default: 0, null: false
    t.float "balanceamount", limit: 53, default: 0.0, null: false
    t.string "requesttype", limit: 80, default: "", null: false
    t.string "sewacode", limit: 50, default: "", null: false
    t.string "requestno", limit: 60, default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "trn_temp_geo_locations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "gc_compcode", limit: 20, null: false
    t.string "gc_latitude", limit: 500, default: "", null: false
    t.string "gc_longitude", limit: 500, default: "", null: false
    t.string "gc_address", limit: 500, default: "", null: false
    t.string "gc_user_id", limit: 30, default: "", null: false
    t.date "gc_date", null: false
    t.time "gc_time", null: false
    t.integer "gc_customer_id", default: 0, null: false
    t.string "gc_visit_number", limit: 20, default: "", null: false
    t.string "gc_duty", limit: 3, default: "", null: false
    t.string "gc_local_time", limit: 15, null: false
    t.string "gc_userimage", limit: 60, default: "", null: false
    t.string "gc_punchtype", limit: 1, default: "N", null: false
    t.string "gc_location", limit: 40, default: "", null: false
    t.string "gc_shiftcode", limit: 4, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gc_compcode"], name: "gc_compcode"
    t.index ["gc_date"], name: "gc_date"
    t.index ["gc_user_id"], name: "gc_user_id"
  end

  create_table "trn_temp_leave_summaries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "tls_compcode", limit: 50, null: false
    t.string "tls_leavetype", limit: 30, null: false
    t.float "tls_credit", limit: 53, default: 0.0, null: false
    t.float "tls_debit", limit: 53, default: 0.0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "trn_temp_salary_registers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "pm_sewacode", limit: 50, default: "", null: false
    t.string "sw_sewadar_name", limit: 90, default: "", null: false
    t.string "categoryname", limit: 90, default: "", null: false
    t.string "catcode", limit: 50, default: "", null: false
    t.string "departcode", limit: 50, default: "", null: false
    t.string "deprtment", limit: 90, default: "", null: false
    t.string "bankaccount", limit: 80, default: "", null: false
    t.float "pm_workingday", limit: 53, default: 0.0, null: false
    t.float "pm_paidleave", limit: 53, default: 0.0, null: false
    t.float "pm_hl", limit: 53, default: 0.0, null: false
    t.float "pm_wo", limit: 53, default: 0.0, null: false
    t.float "pm_absent", limit: 53, default: 0.0, null: false
    t.float "pmactbasic", limit: 53, default: 0.0, null: false
    t.float "pmarear", limit: 53, default: 0.0, null: false
    t.float "pmbasic", limit: 53, default: 0.0, null: false
    t.float "pmdedlicemployee", limit: 53, default: 0.0, null: false
    t.float "pmdedaccomodatamount", limit: 53, default: 0.0, null: false
    t.float "pmdedelectricamount", limit: 53, default: 0.0, null: false
    t.float "uptosixty", limit: 53, default: 0.0, null: false
    t.float "abovesixty", limit: 53, default: 0.0, null: false
    t.float "maadvance", limit: 53, default: 0.0, null: false
    t.float "specialadvance", limit: 53, default: 0.0, null: false
    t.float "wheatadvance", limit: 53, default: 0.0, null: false
    t.float "pmdedhealthsewdarpay", limit: 53, default: 0.0, null: false
    t.float "pmincometaxamount", limit: 53, default: 0.0, null: false
    t.float "pmtotaldeduction", limit: 53, default: 0.0, null: false
    t.float "allowance1", limit: 53, default: 0.0, null: false
    t.float "allowance2", limit: 53, default: 0.0, null: false
    t.float "deduction1", limit: 53, default: 0.0, null: false
    t.float "deduction2", limit: 53, default: 0.0, null: false
    t.float "pmnetpay", limit: 53, default: 0.0, null: false
    t.string "pm_arearremarks", limit: 80, default: "", null: false
    t.string "pm_allowanremarkfirst", limit: 80, default: "", null: false
    t.string "pm_allowanceremksecond", limit: 80, default: "", null: false
    t.string "pm_dedremarkfirst", limit: 80, default: "", null: false
    t.string "pm_dedremarksecond", limit: 80, default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "trn_temp_sewdar_birth_lists", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "sw_sewcode", limit: 60, default: "", null: false
    t.string "sw_sewadar_name", limit: 120, default: "", null: false
    t.string "sw_gender", limit: 2, default: "", null: false
    t.string "sw_image", limit: 80, default: "", null: false
    t.string "sw_depcode", limit: 60, default: "", null: false
    t.date "sw_date_of_birth", null: false
    t.integer "sw_location", default: 0, null: false
    t.string "sw_catgeory", limit: 60, default: "", null: false
    t.string "sw_membtype", limit: 2, default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "trn_transactions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "trns_compcode", limit: 30, null: false
    t.string "trns_depcode", limit: 50, default: "", null: false
    t.string "trns_empcode", limit: 50, null: false
    t.string "trns_rem", limit: 240, null: false
    t.string "trns_type", limit: 80, null: false
    t.string "trns_old", limit: 120, null: false
    t.string "trns_change", limit: 120, null: false
    t.string "trns_mon", limit: 20, default: ""
    t.string "trns_year", limit: 20, default: ""
    t.string "trns_attachemnet", limit: 80, default: "", null: false
    t.date "trns_dated", null: false
    t.string "trns_status", limit: 1, default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "trn_user_accesses", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "menu_name", limit: 50, null: false
    t.string "controller", limit: 50, null: false
    t.string "form_type", limit: 30, null: false
  end

  create_table "trn_user_rights", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "ur_compcode", limit: 30, null: false
    t.string "ur_formname", null: false
    t.string "ur_controller", null: false
    t.integer "ur_user", null: false
    t.string "ur_rights", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trn_voucher_details", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "vd_compcode", limit: 30, null: false
    t.string "vd_voucherno", limit: 30, null: false
    t.date "vd_voucherdate", null: false
    t.string "vd_sewadarcode", limit: 30, null: false
    t.string "vd_requestno", limit: 30, null: false
    t.date "vd_requestdate", null: false
    t.string "vd_requestfor", limit: 30, null: false
    t.float "vd_reqamount", limit: 53, default: 0.0, null: false
    t.string "vd_remark", limit: 300, default: "", null: false
    t.integer "vd_userid", default: 0, null: false
    t.string "vd_status", limit: 1, default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "username", limit: 50, null: false
    t.string "userpassword", limit: 500, null: false
    t.string "firstname", limit: 60, default: "", null: false
    t.string "lastname", limit: 60, default: "", null: false
    t.string "usercompcode", limit: 60, null: false
    t.string "userlocation", limit: 30, default: "", null: false
    t.string "userimage", limit: 100, default: "", null: false
    t.string "usertype", limit: 30, default: "", null: false
    t.string "listmodule", limit: 400, default: "", null: false
    t.string "phonenumber", limit: 11, default: "0", null: false
    t.string "email", limit: 80, default: "0", null: false
    t.string "userstatus", limit: 1, default: "Y", null: false
    t.string "userotpnumber", limit: 7, default: "", null: false
    t.string "sewadarcode", limit: 30, default: "", null: false
    t.string "sewdepart", limit: 50, default: "", null: false
    t.string "zonecode", limit: 50, default: "", null: false
    t.string "branchcode", limit: 50, default: "", null: false
    t.string "userdashboard", limit: 50, default: "", null: false
    t.integer "ecmember", default: 0, null: false
    t.string "suportstfdeparment", limit: 50, default: "", null: false
    t.string "approvalby", limit: 20, default: "", null: false
    t.string "managetype", default: "", null: false
    t.string "allowhrparameter", default: "", null: false
    t.string "loginfirsttime", limit: 1, default: "N", null: false
    t.string "otpnumber", limit: 10, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
