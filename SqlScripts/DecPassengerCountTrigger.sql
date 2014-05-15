USE Railway
GO

create trigger DecPassengerCount
on Ticket
after delete
as
declare @wagonId int, @passCount int, @maxPassCount int

select @wagonId = WagonId from inserted

select @passCount = w.PassengerCount, @maxPassCount = w.MaxPassengerCount from Wagon as w
where w.Id = @wagonId

if @passCount >= 1
begin
	update Wagon set PassengerCount = @passCount - 1
	where Wagon.Id = @wagonId
end
