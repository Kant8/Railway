USE Railway
GO

create trigger CheckPassengerCount
on Ticket
after insert
as
declare @wagonId int, @passCount int, @maxPassCount int

select @wagonId = WagonId from inserted

select @passCount = w.PassengerCount, @maxPassCount = w.MaxPassengerCount from Wagon as w
where w.Id = @wagonId

if @passCount >= @maxPassCount
begin
	rollback transaction	
end
else
begin
	update Wagon set PassengerCount = @passCount + 1
	where Wagon.Id = @wagonId
end

