Program Cryme;
Uses Crt, SysUtils, DateUtils, DOS;

Type
	{Variables used by the Administrator. Necessary to the first run}
	adminData = Record
		name: String;
	end;

programa
	{Variables used by the Prisoner. Necessary to the register form}
	prisonerData = Record
		name: String[50];
	end;

	{Variables used by the Visitor. Necessary to the register form}
	visitorData = Record
		name: String[50];
	end;


procedure loginPanel;
begin
	
end;

Begin
	loginPanel;
End.
