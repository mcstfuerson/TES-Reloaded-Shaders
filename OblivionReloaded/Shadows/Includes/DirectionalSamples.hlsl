//Poisson samples generated via https://github.com/bartwronski/PoissonSamplingGenerator

//TODO: all radius should be resolution dependent but these are good enough for now
const float RADIUS = 6.0f / 8000.0f;
static const float RADIUS_FAR = 2.0f / 8000.0f;
static const uint SAMPLE_NUM = 16;
static const uint SAMPLE_NUM_FAR = 9;
static const uint SAMPLE_TOTAL = 64;
static const float2 POISSON_SAMPLES[SAMPLE_TOTAL] =
{
float2(0.0383598513301f, -0.397496446886f),
float2(-0.0309900081725f, 0.953929464796f),
float2(-0.2836662483f, 0.11414248634f),
float2(0.849795395145f, 0.190973269235f),
float2(-0.309489122431f, -0.819359997541f),
float2(-0.749684750526f, 0.583810985421f),
float2(0.136475589176f, -0.850243489073f),
float2(-0.765140075835f, -0.345855533842f),
float2(0.891971121614f, -0.414398634711f),
float2(0.251375546428f, 0.274862425807f),
float2(-0.411353948332f, -0.384187466462f),
float2(0.665625147709f, 0.59768094136f),
float2(0.301840686141f, 0.948256148804f),
float2(-0.111812944765f, -0.184529516952f),
float2(0.406546484369f, -0.358729218468f),
float2(-0.230758692165f, 0.522033652759f),
float2(0.445442132029f, -0.668679083373f),
float2(-0.592607248009f, 0.0165494427763f),
float2(0.544280981244f, -0.00524911556572f),
float2(-0.533117000471f, 0.740905032191f),
float2(-0.335795537603f, -0.0993230425834f),
float2(0.111478295792f, 0.68593795286f),
float2(-0.677192857825f, 0.344745459014f),
float2(0.480369937244f, 0.44012636579f),
float2(-0.0251646085366f, -0.989139799456f),
float2(0.78889227959f, -0.609708862043f),
float2(-0.0765042038614f, 0.251446677582f),
float2(0.678975324932f, -0.283303052617f),
float2(0.421586807917f, 0.697731265763f),
float2(0.930168457239f, -0.099544086364f),
float2(-0.509399198187f, 0.432351675228f),
float2(0.0591005936145f, -0.0116899632969f),
float2(-0.562124745556f, -0.259206312849f),
float2(0.678492853089f, 0.351596456975f),
float2(-0.165333625548f, 0.76419550954f),
float2(-0.0226156666265f, -0.641324059592f),
float2(0.355788040992f, 0.532740011842f),
float2(-0.838313255968f, 0.0461735898582f),
float2(-0.905168682808f, -0.120645381732f),
float2(0.713532383711f, -0.0790856639175f),
float2(-0.565561110658f, -0.68635680993f),
float2(0.145568327026f, -0.673704649347f),
float2(0.179056968981f, -0.214599597374f),
float2(0.415633462294f, -0.514786458741f),
float2(0.140347264391f, 0.163029700281f),
float2(0.478579944672f, 0.263615806823f),
float2(-0.272293519342f, -0.434279102439f),
float2(-0.392615990189f, 0.650178277556f),
float2(0.191869703205f, 0.858234501972f),
float2(0.631419724066f, -0.502446468129f),
float2(-0.727792835219f, -0.584681707627f),
float2(0.211890707938f, -0.033587943456f),
float2(0.343692482635f, -0.915943924737f),
float2(-0.302367615158f, 0.946223415322f),
float2(0.359427356719f, -0.0534386656426f),
float2(-0.817888651658f, 0.348487823788f),
float2(-0.877685414786f, 0.464700658167f),
float2(0.0617842112688f, 0.454770039189f),
float2(0.349546705306f, 0.166025156667f),
float2(-0.173940202581f, -0.67010524502f),
float2(0.706699690286f, 0.0891129795392f),
float2(-0.741603828453f, 0.163430906857f),
float2(-0.827408846218f, 0.227531845432f),
float2(0.221339403145f, -0.413210697297f),
};

static float RADIUS_SKIN = 1.0f / 2100.0f;
static const uint SAMPLE_NUM_SKIN = 70;
static const uint SAMPLE_SKIN_TOTAL = 120;
static const float2 POISSON_SAMPLES_SKIN[SAMPLE_SKIN_TOTAL] =
{
float2(0.44370313857f, 0.0166131527945f),
float2(-0.978402245915f, -0.0105219624402f),
float2(-0.197569605202f, -0.958306864559f),
float2(-0.329254460067f, 0.86333078858f),
float2(0.5665760576f, -0.807555388842f),
float2(0.512636968961f, 0.844695014133f),
float2(-0.222948915198f, -0.261607611059f),
float2(-0.753600631967f, -0.634735250034f),
float2(0.0534863373862f, 0.438804840168f),
float2(0.898423961371f, -0.331748723574f),
float2(-0.501396034838f, 0.308307894134f),
float2(0.904516655985f, 0.425772937094f),
float2(0.240615411477f, -0.454892519446f),
float2(0.0811251161858f, 0.868056768727f),
float2(-0.903117547258f, 0.399700487895f),
float2(0.475140679264f, 0.454817399654f),
float2(-0.621591221136f, -0.249911097828f),
float2(-0.163427017095f, 0.12138768587f),
float2(0.17856088963f, -0.907348617136f),
float2(-0.657955311582f, 0.647315070434f),
float2(-0.0682180224819f, -0.633229460482f),
float2(-0.411047902076f, -0.662705990278f),
float2(0.85905491594f, 0.0244179975163f),
float2(0.575654162109f, -0.335763993106f),
float2(0.165390674831f, -0.135668972318f),
float2(-0.432962736314f, 0.00501023954146f),
float2(-0.90761466681f, -0.347754225893f),
float2(-0.111780011586f, 0.664708459815f),
float2(0.159257763341f, 0.159517104378f),
float2(-0.712242887301f, 0.0856293417085f),
float2(0.274406733423f, 0.653945162133f),
float2(-0.217056640518f, 0.434528554923f),
float2(0.778960154003f, -0.618618689791f),
float2(0.711941650253f, 0.266094841599f),
float2(0.691542235372f, 0.6559809024f),
float2(0.545595155303f, -0.56672353527f),
float2(-0.395521003058f, 0.638287234587f),
float2(-0.128350466588f, 0.980049316339f),
float2(-0.387612124007f, -0.430110957802f),
float2(0.34991007777f, -0.742073380671f),
float2(0.0295020005107f, -0.356295133049f),
float2(0.729640839629f, -0.170138753285f),
float2(-0.412808463033f, -0.907006206177f),
float2(0.347412530925f, 0.281229858954f),
float2(0.374631571757f, -0.261423150693f),
float2(-0.0247578324654f, -0.0447639229651f),
float2(0.27416636614f, 0.917852195309f),
float2(-0.615504144856f, -0.459227036506f),
float2(-0.588384617459f, -0.78984210633f),
float2(-0.697463145423f, 0.367906965247f),
float2(0.652199533039f, 0.0674789907124f),
float2(0.141250261339f, -0.646760478761f),
float2(-0.807608812599f, -0.127881883016f),
float2(-0.543676514511f, 0.809064874857f),
float2(-0.193034715934f, -0.49877208928f),
float2(0.991330991491f, -0.105815031424f),
float2(-0.360161620301f, 0.181971381876f),
float2(-0.238983514456f, -0.750654042021f),
float2(-0.962003399481f, 0.202345755777f),
float2(-0.0232795721812f, -0.852864203553f),
float2(0.651480298071f, 0.452673594893f),
float2(0.528861013099f, -0.153162864787f),
float2(0.924346379863f, 0.231656497692f),
float2(0.0819571853225f, 0.637397935849f),
float2(0.5367917637f, 0.216477399529f),
float2(-0.223587369904f, -0.071825065191f),
float2(0.49271703913f, 0.648911530116f),
float2(-0.0122775906891f, 0.232603389695f),
float2(0.232930333374f, 0.452766827771f),
float2(-0.430920624277f, -0.198469917197f),
float2(0.184129398072f, -0.188503504825f),
float2(-0.0462873889643f, 0.983296839227f),
float2(-0.873135523745f, -0.417949941308f),
float2(-0.620267501573f, 0.628895006453f),
float2(-0.327250424907f, -0.609348319879f),
float2(0.341207995279f, -0.845017091734f),
float2(0.862192370637f, -0.309495446111f),
float2(0.482283910236f, 0.53354322583f),
float2(-0.690256748053f, 0.0386655626636f),
float2(0.763989533998f, 0.274432372159f),
float2(-0.251795690783f, 0.367582035341f),
float2(-0.0460628253153f, -0.997906675257f),
float2(0.272580954929f, 0.167391508923f),
float2(-0.633517387063f, -0.681778690263f),
float2(-0.535066188013f, 0.259425938179f),
float2(-0.407427771269f, -0.257643325146f),
float2(-0.124684164417f, -0.0589009503986f),
float2(0.0106724676652f, 0.608816094589f),
float2(0.761999887366f, -0.612108998907f),
float2(0.198834112729f, 0.845572572504f),
float2(-0.255911866037f, 0.0952039411366f),
float2(0.149944723535f, -0.638568423264f),
float2(-0.96684611791f, -0.0450981681055f),
float2(-0.794412444226f, 0.433442966199f),
float2(-0.345428337657f, 0.775473595895f),
float2(0.640094250549f, -0.177520532382f),
float2(-0.182515325135f, -0.781615231323f),
float2(0.562045555322f, -0.455903497862f),
float2(-0.429523831066f, -0.829448283814f),
float2(-0.749424712711f, -0.228208095248f),
float2(0.200269030648f, 0.34734964224f),
float2(-0.35304459419f, 0.238137953021f),
float2(0.560110990228f, 0.312471976624f),
float2(0.769883040152f, 0.0682528394199f),
float2(0.434420092189f, -0.169120504663f),
float2(-0.440166478134f, 0.0645516335648f),
float2(-0.0935977751475f, 0.201822442913f),
float2(-0.182054963872f, -0.538340788308f),
float2(0.745013112754f, 0.548202633402f),
float2(0.0348681797657f, -0.375885162805f),
float2(0.00132634507416f, 0.426141610576f),
float2(0.595992500614f, -0.69726436533f),
float2(0.104585641025f, -0.881484397355f),
float2(-0.296607750882f, -0.1211027006f),
float2(0.525530061918f, 0.0831752938312f),
float2(0.469828977583f, 0.822601618062f),
float2(-0.407319625621f, 0.513075533189f),
float2(-0.901565051728f, 0.0995845092282f),
float2(0.2557106362f, 0.598181119875f),
float2(0.438660183924f, -0.658991570085f),
};

static float RADIUS_SKIN_FAR = 1.0f / 4000.0f;
static const uint SAMPLE_NUM_SKIN_FAR = 9;
static const uint SAMPLE_SKIN_FAR_TOTAL = 9;
static const float2 POISSON_SAMPLES_SKIN_FAR[SAMPLE_SKIN_FAR_TOTAL] =
{
float2(0.759888053173f, 0.544159421869f),
float2(0.0450674466889f, -0.878784487971f),
float2(-0.561209800281f, 0.740587868253f),
float2(0.303564616433f, -0.00794036119953f),
float2(-0.957920167247f, -0.078275249338f),
float2(-0.22725526182f, -0.339370198095f),
float2(0.208260110473f, 0.777804958551f),
float2(-0.288038717624f, 0.227310451612f),
float2(0.819235984528f, -0.209781715025f),
};
