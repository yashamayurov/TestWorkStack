--CREATE FUNCTION stack.select_orders_by_item_name
--(@namePosition nvarchar(max))
----RETURNS @resultTable TABLE(idOrder INT, nameCustomer NVARCHAR(MAX), countPosition INT)
--RETURNS TABLE AS
--RETURN
--(	
--	SELECT	o.row_id as idOrder
--			, c.name as nameCustomer 
--			, oi.name
--			, count(oi.row_id) as countPosition 
--	FROM stack.Orders O
--		INNER JOIN stack.OrderItems OI	ON O.row_id = OI.order_id
--		INNER JOIN stack.Customers C	ON c.row_id = O.customer_id
--	WHERE Upper(oi.name) LIKE UPPER (@namePosition) 
--	GROUP BY o.row_id, c.name, oi.name
--)

--select * from stack.select_orders_by_item_name(N'������')
declare @idGroupe INT

SET  @idGroupe = 3;


--select o1.group_name from stack.Orders o1 WHERE o1.row_id = @idGroupe and o1.group_name IS NULL

--WHILE EXISTS(SELECT * FROM stack.Orders O WHERE O.parent_id = @idGroupe)
--BEGIN
-- SELECT * FROM stack.Orders o2 WHERE parent_id = @idGroupe
-- SELECT @idGroupe = row_id FROM stack.Orders o2 WHERE parent_id = @idGroupe
-- PRINT @idGroupe
--END;

--select *
--FROM stack.Orders O
--		LEFT JOIN stack.OrderItems OI	ON O.row_id = OI.order_id
--WHERE O.row_id = @idGroupe 



--EXISTS(select o1.group_name from stack.Orders o1 WHERE o1.row_id = @idGroupe and o1.group_name IS NULL) AND o.parent_id = @idGroupe

WITH OrderTree (ID, ParentID, Name)
AS
(
 SELECT row_id, parent_id, group_name
 FROM stack.Orders O
 WHERE o.row_id = @idGroupe
 UNION ALL
 SELECT row_id, parent_id, group_name
 FROM stack.Orders O
 JOIN OrderTree rec ON o.parent_id = rec.ID
)

SELECT sum(price)
FROM OrderTree OD 
	LEFT JOIN stack.OrderItems OI	ON OD.ID = OI.order_id
GO
-- ������� 2
-- ��� ���������� ����� ������� � ����������� ����������� WITH, ����������� ��������� ����������� ������
-- ��� �������������� �������� �� � �� ��� ����� ������� ����������� ��� ������ HYERARCHY
-- ���� ��������� ������� � ������� �� ���������� ������ � ����������� �����, ��� ��������� �� ������������ ����� ������� ����������� (�� ��� ������)  
CREATE FUNCTION stack.calculate_total_price_for_orders_group(@igGroup INT)
RETURNS INT
AS 
BEGIN
	DECLARE @result INT;
	WITH OrderTree (ID, ParentID, Name) -- ����������� ����������� WITH, ����������� ��������� ����������� ������
	AS
	(
	 SELECT row_id, parent_id, group_name
	 FROM stack.Orders O
	 WHERE o.row_id = @igGroup
	 UNION ALL
	 SELECT row_id, parent_id, group_name
	 FROM stack.Orders O
	 JOIN OrderTree rec ON o.parent_id = rec.ID
	)

	SELECT @result = sum(price)
	FROM OrderTree OD 
		LEFT JOIN stack.OrderItems OI	ON OD.ID = OI.order_id
	RETURN @result
END 
-- ����������
select stack.calculate_total_price_for_orders_group(1) as total_price   -- 703, ��� ������
select stack.calculate_total_price_for_orders_group(2) as total_price   -- 513, ������ '������� ����'
select stack.calculate_total_price_for_orders_group(3) as total_price   -- 510, ������ '����������'
select stack.calculate_total_price_for_orders_group(12) as total_price  -- 190, ������ '����������� ����'
select stack.calculate_total_price_for_orders_group(13) as total_price  -- 190, ����� '�� �������'

SELECT *
FROM stack.Customers C
	INNER JOIN stack.Orders o ON o.customer_id = c.row_id
	INNER JOIN stack.OrderItems oi ON oi.order_id = o.row_id
WHERE --oi.name LIKE N'�������� �������'	
	--and 
	year(o.registered_at) = 2020 

SELECT *
FROM stack.Customers C
WHERE EXISTS(

SELECT *
FROM stack.Orders o
	INNER JOIN stack.OrderItems oi on o.row_id = oi.order_id
WHERE year(o.registered_at) = 2020 
	and NOT(oi.name LIKE N'�������� �������')
	
	and c.row_id = o.customer_id
)
-- ������� 3
-- ��� ���������� ����������� ���������� (�� ����� ������� ����, ��� ��� �� ����� ������ �������� ������ �� �������� ����������)
SELECT c.name
FROM stack.Customers c
WHERE not exists(select row_id					-- ��� ������, � ������� ������������ ������� �������� �������
					FROM stack.Orders o
					WHERE not exists(SELECT * FROM stack.OrderItems oi WHERE o.row_id = oi.order_id AND oi.name like N'�������� �������')
						and year(o.registered_at) = 2020
						and c.row_id = o.customer_id
						) 