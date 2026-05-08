create database cau4;
use cau4;

CREATE TABLE Patients (
    patient_id int unique,
    phone varchar(15) not null,
    total_due DECIMAL(18,3) NOT NULL DEFAULT 0
);

INSERT INTO Patients (patient_id, phone, total_due) 
VALUES
	(1, '0837473373', 1500.000),
	(2, '0999928231', 0),
	(3, '0123454383', 300.000);
    
-- Phần A
-- dữ liệu đầu vào: patient_id, phone
-- dữ liệu đầu ra: total_due, message

-- Đề xuất 2 giải pháp
-- Cách 1: dùng IF/ELSE
-- Nếu có ID thì tìm theo ID
-- Else nếu có Phone thì tìm theo Phone
-- Cách 2: dùng nhiều câu lệnh truy vấn điều kiện trong where
-- vd: WHERE (patient_id = p_patient_id OR p_patient_id IS NULL) AND (phone = p_phone OR p_phone IS NULL)

-- So sánh:
-- Cách 1 sẽ dễ hiểu, rõ ràng hơn, hiệu năng tốt hơn và dùng trong thực tế nhiều hơn
-- Cách 2 sẽ bị phức tạp, khó hiểu, dễ nhầm logic hơn, hiệu năng ko tốt bằng và chắc cũng hiếm được dùng nhiều

-- Luồng xử lý:
-- Nếu cả 2 NULL thì báo lỗi
-- Nếu có ID thì tìm theo ID
-- Else nếu có Phone tìm theo Phone
-- Nếu không tìm thấy: due = 0 + message lỗi
-- Nếu tìm thấy trả về total_due

-- code
delimiter //
create procedure GetPatientDebt (
	in p_patient_id int, 
    in p_phone varchar(15),
    out p_total_due decimal(18, 3),
    out p_message varchar(100)
)
begin 
	if p_patient_id is null and p_phone is null then
		set p_message = 'Lỗi: Vui lòng nhập ID hoặc SĐT';
	else 
		if p_patient_id is not null then
			select total_due into p_total_due from Patients
			where patient_id = p_patient_id;
		else
			select total_due into p_total_due from Patients
            where phone = p_phone;
		end if;
    
		if p_total_due is null then       -- vì nếu id = 9999 ko có trong hệ thống thì sẽ ko thể trả về total_due dẫn đến vc hệ thống đánh nó null
			set p_total_due = 0;
			set p_message = 'Không tìm thấy bệnh nhân';
		else 
			set p_message = 'Tra cứu thành công';
		end if;
	end if;
end //
delimiter ;

-- test
call GetPatientDebt (1, null, @total_due, @message);
select @total_due, @message;

call GetPatientDebt (null, '0999928231',  @total_due, @message);
select @total_due, @message;

call GetPatientDebt (null, null,  @total_due, @message);
select @message;

call GetPatientDebt (999, '0000999',  @total_due, @message);
select @total_due, @message;
