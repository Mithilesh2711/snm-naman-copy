class TrnAttendanceList < ApplicationRecord
    def self.to_attendancelist
        attributes1 = %w{EmpCode Name Department TranDate ShiftCode ArrivalTime DepartureTime WorkingHrs LateHrs EarlyHrs OverTime MissPunch Remark}
        attributes = %w{al_empcode empname departname bdated al_shift al_arrtime all_deptime al_workhrs al_latehrs al_earlhrs al_overtime al_misspunch remark}
        
        CSV.generate(:headers=> true) do |csv|
          csv << attributes1
          all.each do |user|
            departname = ""
            desnation  = ""
            empname    = ""
            empobj     = get_employee_detail(user.al_compcode,user.al_empcode)
             if empobj
                empname = empobj.emp_name
                 dpobj =  get_department_detail(empobj.emp_compcode,empobj.emp_department)
                 if dpobj
                   departname = dpobj.dp_name
                 end

                 desobj =  get_designation_detail(empobj.emp_compcode,empobj.emp_designation)
                 if desobj
                   desnation = desobj.mydescript
                 end
             end
               if user.al_presabsent == 'P'
                 user.remark = 'Present'
               elsif user.al_presabsent == 'A'
                 user.remark = 'Absent'
               elsif user.al_presabsent == 'HD'
                 user.remark = 'Half Day'
               elsif user.al_presabsent == 'HL'
                 user.remark = 'Holiday'
               elsif user.al_presabsent == 'WO'
                 user.remark = 'Week Off'
               end
               user.departname = departname
               user.desnation  = desnation
               user.empname    = empname
               
              csv << attributes.map{ |attr| user.send(attr) }
          end
        end
    end
    private
  def self.get_department_detail(compcode,id)
    depobj =  MstDepartment.where("dp_compcode = ? AND id= ?",compcode,id).first
    return depobj
end
private
def self.get_designation_detail(compcode,id)
depobj =  Designation.select("description as mydescript").where("compCode = ? AND id= ?",compcode,id).first
  return depobj
end
private
def self.get_employee_detail(compcode,empcode)
    empobj = MstEmployee.where("emp_compcode =? AND id = ?",compcode,empcode).first
    return empobj
end

private
def self.get_department_list(compcode,depid)
  depobj =  MstDepartment.where("dp_compcode= ? AND id =?",compcode,depid).first
  return depobj
end
end
