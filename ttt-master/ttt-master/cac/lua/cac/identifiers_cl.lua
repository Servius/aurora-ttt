CAC.Identifiers        = CAC.Identifiers        or {}
CAC.InverseIdentifiers = CAC.InverseIdentifiers or {}

CAC.IDb01208d6 =
{
	"fd35edd281c2b469cd42a76ca02a9a89",
	"65b837e123b74be70adc188914f3f56b5811",
	"b0155b9d96913f718341ba6ce523c2a899d1fd6d453da2e7c0cc657502a593f31e1110e8",
	"89c1aa4529eb3711b85ac721eb71240a6eb18eb0565c9eb5411e",
	"a58fcc800f5123ef1574e40f98429c6391372362d68cf1c5ec89c6ae885f4d0dc2813002",
	"82a7b617ebdc7f1178a3e16d0f6eaf1b3f77807c471cb220e4cc72d13e9f2dcc5d959181f44083dd07961a4414fd7e208a5a84cb7165fbdfaf3fdd8528ac9b35",
}

CAC.Identifiers.AdminChannelName = "⁬‭⁬⁭⁪​‎⁪‬.‌​⁭⁮‌⁭​⁬⁭"

for k, v in pairs (CAC.Identifiers) do
	CAC.InverseIdentifiers [v] = k
end
