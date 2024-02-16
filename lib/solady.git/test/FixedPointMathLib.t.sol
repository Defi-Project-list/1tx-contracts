// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./utils/SoladyTest.sol";
import { FixedPointMathLib } from "../src/utils/FixedPointMathLib.sol";

contract FixedPointMathLibTest is SoladyTest {
    function testExpWad() public {
        assertEq(FixedPointMathLib.expWad(-41_446_531_673_892_822_312), 1);
        assertEq(FixedPointMathLib.expWad(-41_446_531_673_892_822_313), 0);

        assertEq(FixedPointMathLib.expWad(-3e18), 49_787_068_367_863_942);
        assertEq(FixedPointMathLib.expWad(-2e18), 135_335_283_236_612_691);
        assertEq(FixedPointMathLib.expWad(-1e18), 367_879_441_171_442_321);

        assertEq(FixedPointMathLib.expWad(-0.5e18), 606_530_659_712_633_423);
        assertEq(FixedPointMathLib.expWad(-0.3e18), 740_818_220_681_717_866);

        assertEq(FixedPointMathLib.expWad(0), 1_000_000_000_000_000_000);

        assertEq(FixedPointMathLib.expWad(0.3e18), 1_349_858_807_576_003_103);
        assertEq(FixedPointMathLib.expWad(0.5e18), 1_648_721_270_700_128_146);

        assertEq(FixedPointMathLib.expWad(1e18), 2_718_281_828_459_045_235);
        assertEq(FixedPointMathLib.expWad(2e18), 7_389_056_098_930_650_227);
        assertEq(FixedPointMathLib.expWad(3e18), 20_085_536_923_187_667_741);
        // True value: 20085536923187667740.92

        assertEq(FixedPointMathLib.expWad(10e18), 22_026_465_794_806_716_516_980);
        // True value: 22026465794806716516957.90
        // Relative error 9.987984547746668e-22

        assertEq(FixedPointMathLib.expWad(50e18), 5_184_705_528_587_072_464_148_529_318_587_763_226_117);
        // True value: 5184705528587072464_087453322933485384827.47
        // Relative error: 1.1780031733243328e-20

        assertEq(
            FixedPointMathLib.expWad(100e18),
            26_881_171_418_161_354_484_134_666_106_240_937_146_178_367_581_647_816_351_662_017
        );
        // True value: 268811714181613544841_26255515800135873611118773741922415191608
        // Relative error: 3.128803544297531e-22

        assertEq(
            FixedPointMathLib.expWad(135_305_999_368_893_231_588),
            57_896_044_618_658_097_650_144_101_621_524_338_577_433_870_140_581_303_254_786_265_309_376_407_432_913
        );
        // True value: 578960446186580976_49816762928942336782129491980154662247847962410455084893091
        // Relative error: 5.653904247484822e-21
    }

    // Notes on lambertW0Wad:
    //
    // If you want to attempt finding a better approximation, look at
    // https://github.com/recmo/experiment-solexp/blob/main/approximate_mpmath.ipynb
    // I somehow can't get it to reproduce the approximation constants for `lnWad`.
    // Let me know if you can get the code to reproduce the approximation constants for `lnWad`.

    event TestingLambertW0WadMonotonicallyIncreasing(
        int256 a, int256 b, int256 w0a, int256 w0b, bool success, uint256 gasUsed
    );

    int256 internal constant _ONE_DIV_EXP = 367_879_441_171_442_321;
    int256 internal constant _LAMBERT_W0_MIN = -367_879_441_171_442_321;
    int256 internal constant _EXP = 2_718_281_828_459_045_235;
    int256 internal constant _WAD = 10 ** 18;

    function testLambertW0WadKnownValues() public {
        _checkLambertW0Wad(0, 0);
        _checkLambertW0Wad(1, 1);
        _checkLambertW0Wad(2, 2);
        _checkLambertW0Wad(3, 2);
        _checkLambertW0Wad(131_071, 131_070);
        _checkLambertW0Wad(17_179_869_183, 17_179_868_887);
        _checkLambertW0Wad(1_000_000_000_000_000_000, 567_143_290_409_783_872);
        _checkLambertW0Wad(-3_678_794_411_715, -3_678_807_945_318);
        _checkLambertW0Wad(_LAMBERT_W0_MIN, -999_999_999_741_585_709);
        // These are exact values.
        _checkLambertW0Wad(2 ** 255 - 1, 130_435_123_404_408_416_612);
        _checkLambertW0Wad(2 ** 254 - 1, 129_747_263_755_102_316_133);
        _checkLambertW0Wad(2 ** 253 - 1, 129_059_431_996_357_330_139);
        _checkLambertW0Wad(2 ** 252 - 1, 128_371_628_422_812_486_425);
        _checkLambertW0Wad(2 ** 251 - 1, 127_683_853_333_788_079_721);
        _checkLambertW0Wad(2 ** 250 - 1, 126_996_107_033_385_166_927);
        _checkLambertW0Wad(2 ** 249 - 1, 126_308_389_830_587_715_420);
        _checkLambertW0Wad(2 ** 248 - 1, 125_620_702_039_367_489_656);
        _checkLambertW0Wad(2 ** 247 - 1, 124_933_043_978_791_764_502);
        _checkLambertW0Wad(2 ** 246 - 1, 124_245_415_973_133_957_088);
        _checkLambertW0Wad(2 ** 245 - 1, 123_557_818_351_987_272_451);
        _checkLambertW0Wad(2 ** 244 - 1, 122_870_251_450_381_461_880);
        _checkLambertW0Wad(2 ** 243 - 1, 122_182_715_608_902_796_703);
        _checkLambertW0Wad(2 ** 242 - 1, 121_495_211_173_817_364_188);
        _checkLambertW0Wad(2 ** 241 - 1, 120_807_738_497_197_796_422);
        _checkLambertW0Wad(2 ** 240 - 1, 120_120_297_937_053_547_320);
        _checkLambertW0Wad(2 ** 239 - 1, 119_432_889_857_464_837_488);
        _checkLambertW0Wad(2 ** 238 - 1, 118_745_514_628_720_391_363);
        _checkLambertW0Wad(2 ** 237 - 1, 118_058_172_627_459_096_009);
        _checkLambertW0Wad(2 ** 236 - 1, 117_370_864_236_815_716_134);
        _checkLambertW0Wad(2 ** 235 - 1, 116_683_589_846_570_805_279);
        _checkLambertW0Wad(2 ** 234 - 1, 115_996_349_853_304_958_814);
        _checkLambertW0Wad(2 ** 233 - 1, 115_309_144_660_557_560_280);
        _checkLambertW0Wad(2 ** 232 - 1, 114_621_974_678_990_178_815);
        _checkLambertW0Wad(2 ** 231 - 1, 113_934_840_326_554_781_918);
        _checkLambertW0Wad(2 ** 230 - 1, 113_247_742_028_666_934_564);
        _checkLambertW0Wad(2 ** 229 - 1, 112_560_680_218_384_162_820);
        _checkLambertW0Wad(2 ** 228 - 1, 111_873_655_336_589_667_598);
        _checkLambertW0Wad(2 ** 227 - 1, 111_186_667_832_181_581_935);
        _checkLambertW0Wad(2 ** 226 - 1, 110_499_718_162_267_973_459);
        _checkLambertW0Wad(2 ** 225 - 1, 109_812_806_792_367_802_251);
        _checkLambertW0Wad(2 ** 224 - 1, 109_125_934_196_618_053_331);
        _checkLambertW0Wad(2 ** 223 - 1, 108_439_100_857_987_272_488);
        _checkLambertW0Wad(2 ** 222 - 1, 107_752_307_268_495_744_067);
        _checkLambertW0Wad(2 ** 221 - 1, 107_065_553_929_442_559_763);
        _checkLambertW0Wad(2 ** 220 - 1, 106_378_841_351_639_838_444);
        _checkLambertW0Wad(2 ** 219 - 1, 105_692_170_055_654_368_478);
        _checkLambertW0Wad(2 ** 218 - 1, 105_005_540_572_056_956_171);
        _checkLambertW0Wad(2 ** 217 - 1, 104_318_953_441_679_776_592);
        _checkLambertW0Wad(2 ** 216 - 1, 103_632_409_215_882_036_434);
        _checkLambertW0Wad(2 ** 215 - 1, 102_945_908_456_824_272_609);
        _checkLambertW0Wad(2 ** 214 - 1, 102_259_451_737_751_625_038);
        _checkLambertW0Wad(2 ** 213 - 1, 101_573_039_643_286_437_675);
        _checkLambertW0Wad(2 ** 212 - 1, 100_886_672_769_730_558_166);
        _checkLambertW0Wad(2 ** 211 - 1, 100_200_351_725_377_723_788);
        _checkLambertW0Wad(2 ** 210 - 1, 99_514_077_130_836_439_501);
        _checkLambertW0Wad(2 ** 209 - 1, 98_827_849_619_363_773_067);
        _checkLambertW0Wad(2 ** 208 - 1, 98_141_669_837_210_512_407);
        _checkLambertW0Wad(2 ** 207 - 1, 97_455_538_443_978_151_616);
        _checkLambertW0Wad(2 ** 206 - 1, 96_769_456_112_988_194_563);
        _checkLambertW0Wad(2 ** 205 - 1, 96_083_423_531_664_288_650);
        _checkLambertW0Wad(2 ** 204 - 1, 95_397_441_401_927_726_359);
        _checkLambertW0Wad(2 ** 203 - 1, 94_711_510_440_606_878_644);
        _checkLambertW0Wad(2 ** 202 - 1, 94_025_631_379_861_152_095);
        _checkLambertW0Wad(2 ** 201 - 1, 93_339_804_967_620_091_367);
        _checkLambertW0Wad(2 ** 200 - 1, 92_654_031_968_038_279_517);
        _checkLambertW0Wad(2 ** 199 - 1, 91_968_313_161_966_721_893);
        _checkLambertW0Wad(2 ** 198 - 1, 91_282_649_347_441_434_152);
        _checkLambertW0Wad(2 ** 197 - 1, 90_597_041_340_189_991_908);
        _checkLambertW0Wad(2 ** 196 - 1, 89_911_489_974_156_838_659);
        _checkLambertW0Wad(2 ** 195 - 1, 89_225_996_102_048_190_100);
        _checkLambertW0Wad(2 ** 194 - 1, 88_540_560_595_897_416_858);
        _checkLambertW0Wad(2 ** 193 - 1, 87_855_184_347_651_834_275);
        _checkLambertW0Wad(2 ** 192 - 1, 87_169_868_269_781_877_263);
        _checkLambertW0Wad(2 ** 191 - 1, 86_484_613_295_913_690_725);
        _checkLambertW0Wad(2 ** 190 - 1, 85_799_420_381_486_221_653);
        _checkLambertW0Wad(2 ** 189 - 1, 85_114_290_504_433_958_190);
        _checkLambertW0Wad(2 ** 188 - 1, 84_429_224_665_896_523_735);
        _checkLambertW0Wad(2 ** 187 - 1, 83_744_223_890_956_400_983);
        _checkLambertW0Wad(2 ** 186 - 1, 83_059_289_229_406_131_801);
        _checkLambertW0Wad(2 ** 185 - 1, 82_374_421_756_546_414_467);
        _checkLambertW0Wad(2 ** 184 - 1, 81_689_622_574_016_600_237);
        _checkLambertW0Wad(2 ** 183 - 1, 81_004_892_810_659_176_931);
        _checkLambertW0Wad(2 ** 182 - 1, 80_320_233_623_419_918_558);
        _checkLambertW0Wad(2 ** 181 - 1, 79_635_646_198_285_477_393);
        _checkLambertW0Wad(2 ** 180 - 1, 78_951_131_751_260_298_782);
        _checkLambertW0Wad(2 ** 179 - 1, 78_266_691_529_384_849_812);
        _checkLambertW0Wad(2 ** 178 - 1, 77_582_326_811_797_271_395);
        _checkLambertW0Wad(2 ** 177 - 1, 76_898_038_910_840_689_756);
        _checkLambertW0Wad(2 ** 176 - 1, 76_213_829_173_218_558_571);
        _checkLambertW0Wad(2 ** 175 - 1, 75_529_698_981_200_547_567);
        _checkLambertW0Wad(2 ** 174 - 1, 74_845_649_753_881_648_207);
        _checkLambertW0Wad(2 ** 173 - 1, 74_161_682_948_497_332_759);
        _checkLambertW0Wad(2 ** 172 - 1, 73_477_800_061_797_780_656);
        _checkLambertW0Wad(2 ** 171 - 1, 72_794_002_631_484_376_331);
        _checkLambertW0Wad(2 ** 170 - 1, 72_110_292_237_711_886_966);
        _checkLambertW0Wad(2 ** 169 - 1, 71_426_670_504_659_947_705);
        _checkLambertW0Wad(2 ** 168 - 1, 70_743_139_102_177_717_275);
        _checkLambertW0Wad(2 ** 167 - 1, 70_059_699_747_505_819_935);
        _checkLambertW0Wad(2 ** 166 - 1, 69_376_354_207_079_961_679);
        _checkLambertW0Wad(2 ** 165 - 1, 68_693_104_298_420_901_379);
        _checkLambertW0Wad(2 ** 164 - 1, 68_009_951_892_115_772_747);
        _checkLambertW0Wad(2 ** 163 - 1, 67_326_898_913_896_092_682);
        _checkLambertW0Wad(2 ** 162 - 1, 66_643_947_346_818_157_796);
        _checkLambertW0Wad(2 ** 161 - 1, 65_961_099_233_551_926_143);
        _checkLambertW0Wad(2 ** 160 - 1, 65_278_356_678_784_907_905);
        _checkLambertW0Wad(2 ** 159 - 1, 64_595_721_851_748_049_983);
        _checkLambertW0Wad(2 ** 158 - 1, 63_913_196_988_871_098_107);
        _checkLambertW0Wad(2 ** 157 - 1, 63_230_784_396_575_459_844);
        _checkLambertW0Wad(2 ** 156 - 1, 62_548_486_454_213_176_429);
        _checkLambertW0Wad(2 ** 155 - 1, 61_866_305_617_161_244_980);
        _checkLambertW0Wad(2 ** 154 - 1, 61_184_244_420_081_220_067);
        _checkLambertW0Wad(2 ** 153 - 1, 60_502_305_480_354_769_865);
        _checkLambertW0Wad(2 ** 152 - 1, 59_820_491_501_706_673_077);
        _checkLambertW0Wad(2 ** 151 - 1, 59_138_805_278_027_624_755);
        _checkLambertW0Wad(2 ** 150 - 1, 58_457_249_697_410_179_101);
        _checkLambertW0Wad(2 ** 149 - 1, 57_775_827_746_412_203_235);
        _checkLambertW0Wad(2 ** 148 - 1, 57_094_542_514_563_356_374);
        _checkLambertW0Wad(2 ** 147 - 1, 56_413_397_199_131_353_678);
        _checkLambertW0Wad(2 ** 146 - 1, 55_732_395_110_166_133_991);
        _checkLambertW0Wad(2 ** 145 - 1, 55_051_539_675_841_537_897);
        _checkLambertW0Wad(2 ** 144 - 1, 54_370_834_448_115_730_535);
        _checkLambertW0Wad(2 ** 143 - 1, 53_690_283_108_733_387_465);
        _checkLambertW0Wad(2 ** 142 - 1, 53_009_889_475_594_618_649);
        _checkLambertW0Wad(2 ** 141 - 1, 52_329_657_509_517_754_228);
        _checkLambertW0Wad(2 ** 140 - 1, 51_649_591_321_425_477_661);
        _checkLambertW0Wad(2 ** 139 - 1, 50_969_695_179_986_390_948);
        _checkLambertW0Wad(2 ** 138 - 1, 50_289_973_519_746_960_243);
        _checkLambertW0Wad(2 ** 137 - 1, 49_610_430_949_791_948_630);
        _checkLambertW0Wad(2 ** 136 - 1, 48_931_072_262_974_930_811);
        _checkLambertW0Wad(2 ** 135 - 1, 48_251_902_445_764_340_905);
        _checkLambertW0Wad(2 ** 134 - 1, 47_572_926_688_754_773_801);
        _checkLambertW0Wad(2 ** 133 - 1, 46_894_150_397_897_992_742);
        _checkLambertW0Wad(2 ** 132 - 1, 46_215_579_206_513_348_095);
        _checkLambertW0Wad(2 ** 131 - 1, 45_537_218_988_143_149_666);
        _checkLambertW0Wad(2 ** 130 - 1, 44_859_075_870_325_031_417);
        _checkLambertW0Wad(2 ** 129 - 1, 44_181_156_249_360_587_882);
        _checkLambertW0Wad(2 ** 128 - 1, 43_503_466_806_167_642_613);
        _checkLambertW0Wad(2 ** 127 - 1, 42_826_014_523_312_541_917);
        _checkLambertW0Wad(2 ** 126 - 1, 42_148_806_703_328_979_292);
        _checkLambertW0Wad(2 ** 125 - 1, 41_471_850_988_441_194_251);
        _checkLambertW0Wad(2 ** 124 - 1, 40_795_155_381_822_122_767);
        _checkLambertW0Wad(2 ** 123 - 1, 40_118_728_270_531_400_808);
        _checkLambertW0Wad(2 ** 122 - 1, 39_442_578_450_294_263_667);
        _checkLambertW0Wad(2 ** 121 - 1, 38_766_715_152_300_604_375);
        _checkLambertW0Wad(2 ** 120 - 1, 38_091_148_072_224_059_569);
        _checkLambertW0Wad(2 ** 119 - 1, 37_415_887_401_684_336_100);
        _checkLambertW0Wad(2 ** 118 - 1, 36_740_943_862_402_491_609);
        _checkLambertW0Wad(2 ** 117 - 1, 36_066_328_743_329_022_902);
        _checkLambertW0Wad(2 ** 116 - 1, 35_392_053_941_058_967_434);
        _checkLambertW0Wad(2 ** 115 - 1, 34_718_132_003_887_455_986);
        _checkLambertW0Wad(2 ** 114 - 1, 34_044_576_179_904_059_477);
        _checkLambertW0Wad(2 ** 113 - 1, 33_371_400_469_575_784_902);
        _checkLambertW0Wad(2 ** 112 - 1, 32_698_619_683_327_803_297);
        _checkLambertW0Wad(2 ** 111 - 1, 32_026_249_504_699_254_799);
        _checkLambertW0Wad(2 ** 110 - 1, 31_354_306_559_730_344_521);
        _checkLambertW0Wad(2 ** 109 - 1, 30_682_808_493_328_298_780);
        _checkLambertW0Wad(2 ** 108 - 1, 30_011_774_053_465_850_808);
        _checkLambertW0Wad(2 ** 107 - 1, 29_341_223_184_189_485_097);
        _checkLambertW0Wad(2 ** 106 - 1, 28_671_177_128_558_970_924);
        _checkLambertW0Wad(2 ** 105 - 1, 28_001_658_542_808_735_364);
        _checkLambertW0Wad(2 ** 104 - 1, 27_332_691_623_220_201_135);
        _checkLambertW0Wad(2 ** 103 - 1, 26_664_302_247_428_250_682);
        _checkLambertW0Wad(2 ** 102 - 1, 25_996_518_132_161_712_657);
        _checkLambertW0Wad(2 ** 101 - 1, 25_329_369_009_746_106_264);
        _checkLambertW0Wad(2 ** 100 - 1, 24_662_886_826_087_826_761);
        _checkLambertW0Wad(2 ** 99 - 1, 23_997_105_963_326_166_352);
        _checkLambertW0Wad(2 ** 98 - 1, 23_332_063_490_900_058_530);
        _checkLambertW0Wad(2 ** 97 - 1, 22_667_799_449_451_523_321);
        _checkLambertW0Wad(2 ** 96 - 1, 22_004_357_172_804_292_983);
        _checkLambertW0Wad(2 ** 95 - 1, 21_341_783_654_247_925_671);
        _checkLambertW0Wad(2 ** 94 - 1, 20_680_129_964_567_978_803);
        _checkLambertW0Wad(2 ** 93 - 1, 20_019_451_730_746_615_034);
        _checkLambertW0Wad(2 ** 92 - 1, 19_359_809_686_086_176_343);
        _checkLambertW0Wad(2 ** 91 - 1, 18_701_270_304_772_358_157);
        _checkLambertW0Wad(2 ** 90 - 1, 18_043_906_536_712_772_323);
        _checkLambertW0Wad(2 ** 89 - 1, 17_387_798_662_016_868_795);
        _checkLambertW0Wad(2 ** 88 - 1, 16_733_035_288_929_945_451);
        _checkLambertW0Wad(2 ** 87 - 1, 16_079_714_524_670_107_222 + 1);
        _checkLambertW0Wad(2 ** 86 - 1, 15_427_945_355_807_184_379);
        _checkLambertW0Wad(2 ** 85 - 1, 14_777_849_284_057_868_231);
        _checkLambertW0Wad(2 ** 84 - 1, 14_129_562_275_318_189_632);
        _checkLambertW0Wad(2 ** 83 - 1, 13_483_237_095_324_880_705);
        _checkLambertW0Wad(2 ** 82 - 1, 12_839_046_125_789_215_063);
        _checkLambertW0Wad(2 ** 81 - 1, 12_197_184_781_931_118_579);
        _checkLambertW0Wad(2 ** 80 - 1, 11_557_875_688_514_566_228 - 1);
        _checkLambertW0Wad(2 ** 79 - 1, 10_921_373_820_226_202_580);
        _checkLambertW0Wad(2 ** 78 - 1, 10_287_972_878_516_218_499);
        _checkLambertW0Wad(2 ** 77 - 1, 9_658_013_267_990_184_319);
        _checkLambertW0Wad(2 ** 76 - 1, 9_031_892_161_491_509_531);
        _checkLambertW0Wad(2 ** 75 - 1, 8_410_076_319_328_428_686);
        _checkLambertW0Wad(2 ** 74 - 1, 7_793_118_576_966_979_948);
        _checkLambertW0Wad(2 ** 73 - 1, 7_181_679_269_695_846_234);
        _checkLambertW0Wad(2 ** 72 - 1, 6_576_554_370_186_862_926);
        _checkLambertW0Wad(2 ** 71 - 1, 5_978_712_844_468_804_878 - 1);
        _checkLambertW0Wad(2 ** 70 - 1, 5_389_346_779_005_776_683);
        _checkLambertW0Wad(2 ** 69 - 1, 4_809_939_316_762_921_936);
        _checkLambertW0Wad(2 ** 68 - 1, 4_242_357_480_017_482_271);
        _checkLambertW0Wad(2 ** 67 - 1, 3_688_979_548_845_126_287);
        _checkLambertW0Wad(2 ** 66 - 1, 3_152_869_312_105_232_629);
        _checkLambertW0Wad(2 ** 65 - 1, 2_638_010_157_689_274_059);
        _checkLambertW0Wad(2 ** 64 - 1, 2_149_604_165_721_149_566);
        _checkLambertW0Wad(2 ** 63 - 1, 1_694_407_549_795_038_335);
        _checkLambertW0Wad(2 ** 62 - 1, 1_280_973_323_147_500_590);
        _checkLambertW0Wad(2 ** 61 - 1, 919_438_481_612_859_603);
        _checkLambertW0Wad(2 ** 60 - 1, 620_128_202_996_354_327);
        _checkLambertW0Wad(2 ** 59 - 1, 390_213_425_026_895_126);
        _checkLambertW0Wad(2 ** 58 - 1, 229_193_491_169_149_614);
        _checkLambertW0Wad(2 ** 57 - 1, 126_935_310_044_982_397);
        _checkLambertW0Wad(2 ** 56 - 1, 67_363_429_834_711_483);
        _checkLambertW0Wad(2 ** 55 - 1, 34_796_675_828_817_814);
        _checkLambertW0Wad(2 ** 54 - 1, 17_698_377_658_513_340);
        _checkLambertW0Wad(2 ** 53 - 1, 8_927_148_493_627_578);
        _checkLambertW0Wad(2 ** 52 - 1, 4_483_453_146_102_402);
        _checkLambertW0Wad(2 ** 51 - 1, 2_246_746_269_994_097);
        _checkLambertW0Wad(2 ** 50 - 1, 1_124_634_392_838_166);
        _checkLambertW0Wad(2 ** 49 - 1, 562_633_308_112_667);
        _checkLambertW0Wad(2 ** 48 - 1, 281_395_781_982_528);
        _checkLambertW0Wad(2 ** 47 - 1, 140_717_685_495_042);
        _checkLambertW0Wad(2 ** 46 - 1, 70_363_792_940_114);
        _checkLambertW0Wad(2 ** 45 - 1, 35_183_134_214_121);
        _checkLambertW0Wad(2 ** 44 - 1, 17_591_876_567_571);
        _checkLambertW0Wad(2 ** 43 - 1, 8_796_015_651_975);
        _checkLambertW0Wad(2 ** 42 - 1, 4_398_027_168_417);
        _checkLambertW0Wad(2 ** 41 - 1, 2_199_018_419_863);
        _checkLambertW0Wad(2 ** 40 - 1, 1_099_510_418_851);
        _checkLambertW0Wad(2 ** 39 - 1, 549_755_511_655);
        _checkLambertW0Wad(2 ** 38 - 1, 274_877_831_385);
        _checkLambertW0Wad(2 ** 37 - 1, 137_438_934_581);
        _checkLambertW0Wad(2 ** 36 - 1, 68_719_472_012);
        _checkLambertW0Wad(2 ** 35 - 1, 34_359_737_186);
        _checkLambertW0Wad(2 ** 34 - 1, 17_179_868_887);
        _checkLambertW0Wad(2 ** 33 - 1, 8_589_934_517);
        _checkLambertW0Wad(2 ** 32 - 1, 4_294_967_276);
        _checkLambertW0Wad(2 ** 31 - 1, 2_147_483_642);
        _checkLambertW0Wad(2 ** 30 - 1, 1_073_741_821);
        _checkLambertW0Wad(2 ** 29 - 1, 536_870_910);
        _checkLambertW0Wad(2 ** 28 - 1, 268_435_454);
        _checkLambertW0Wad(2 ** 27 - 1, 134_217_726);
        _checkLambertW0Wad(2 ** 26 - 1, 67_108_862);
        _checkLambertW0Wad(2 ** 25 - 1, 33_554_430);
        _checkLambertW0Wad(2 ** 24 - 1, 16_777_214);
        _checkLambertW0Wad(2 ** 23 - 1, 8_388_606);
        _checkLambertW0Wad(2 ** 22 - 1, 4_194_302);
        _checkLambertW0Wad(2 ** 21 - 1, 2_097_150);
        _checkLambertW0Wad(2 ** 20 - 1, 1_048_574);
        _checkLambertW0Wad(2 ** 19 - 1, 524_286);
        _checkLambertW0Wad(2 ** 18 - 1, 262_142);
        _checkLambertW0Wad(2 ** 17 - 1, 131_070);
        _checkLambertW0Wad(2 ** 16 - 1, 65_534);
        _checkLambertW0Wad(2 ** 15 - 1, 32_766);
        _checkLambertW0Wad(2 ** 14 - 1, 16_382);
        _checkLambertW0Wad(2 ** 13 - 1, 8190);
        _checkLambertW0Wad(2 ** 12 - 1, 4094);
        _checkLambertW0Wad(2 ** 11 - 1, 2046);
        _checkLambertW0Wad(2 ** 10 - 1, 1022);
        _checkLambertW0Wad(2 ** 9 - 1, 510);
        _checkLambertW0Wad(2 ** 8 - 1, 254);
    }

    function testLambertW0WadRevertsForOutOfDomain() public {
        FixedPointMathLib.lambertW0Wad(_LAMBERT_W0_MIN);
        for (int256 i = 0; i <= 10; ++i) {
            vm.expectRevert(FixedPointMathLib.OutOfDomain.selector);
            FixedPointMathLib.lambertW0Wad(_LAMBERT_W0_MIN - 1 - i);
        }
        vm.expectRevert(FixedPointMathLib.OutOfDomain.selector);
        FixedPointMathLib.lambertW0Wad(-type(int256).max);
    }

    function _checkLambertW0Wad(int256 x, int256 expected) internal {
        unchecked {
            uint256 gasBefore = gasleft();
            int256 w = FixedPointMathLib.lambertW0Wad(x);
            uint256 gasUsed = gasBefore - gasleft();
            emit LogInt("x", x);
            emit LogUint("gasUsed", gasUsed);
            assertEq(w, expected);
        }
    }

    function testLambertW0WadAccuracy() public {
        testLambertW0WadAccuracy(uint184(int184(_testLamberW0WadAccuracyThres())));
        testLambertW0WadAccuracy(2 ** 184 - 1);
    }

    function testLambertW0WadAccuracy(uint184 a) public {
        int256 x = int256(int184(a));
        if (x >= _testLamberW0WadAccuracyThres()) {
            int256 l = FixedPointMathLib.lnWad(x);
            int256 r = x * l / _WAD;
            int256 w = FixedPointMathLib.lambertW0Wad(r);
            assertLt(FixedPointMathLib.abs(l - w), 0xff);
        }
    }

    function _testLamberW0WadAccuracyThres() internal pure returns (int256) {
        unchecked {
            return _ONE_DIV_EXP + _ONE_DIV_EXP * 0.01 ether / 1 ether;
        }
    }

    function testLambertW0WadWithinBounds(int256 x) public {
        if (x <= 0) x = _boundLambertW0WadInput(x);
        int256 w = FixedPointMathLib.lambertW0Wad(x);
        assertTrue(w <= x);
        unchecked {
            if (x > _EXP) {
                int256 l = FixedPointMathLib.lnWad(x);
                assertGt(l, 0);
                int256 ll = FixedPointMathLib.lnWad(l);
                int256 q = ll * _WAD;
                int256 lower = l - ll + q / (2 * l);
                if (x > _EXP + 4) {
                    assertLt(lower, w + 1);
                } else {
                    assertLt(lower, w + 2);
                }
                int256 upper = l - ll + (q * _EXP) / (l * (_EXP - _WAD)) + 1;
                assertLt(w, upper);
            }
        }
    }

    function testLambertW0WadWithinBounds() public {
        unchecked {
            for (int256 i = -10; i != 20; ++i) {
                testLambertW0WadWithinBounds(_EXP + i);
            }
            testLambertW0WadWithinBounds(type(int256).max);
        }
    }

    function testLambertW0WadMonotonicallyIncreasing() public {
        unchecked {
            for (uint256 i; i <= 256; ++i) {
                uint256 x = 1 << i;
                testLambertW0WadMonotonicallyIncreasingAround(int256(x));
                testLambertW0WadMonotonicallyIncreasingAround(int256(x - 1));
            }
            for (uint256 i; i <= 57; ++i) {
                uint256 x = 1 << i;
                testLambertW0WadMonotonicallyIncreasingAround(-int256(x));
                testLambertW0WadMonotonicallyIncreasingAround(-int256(x - 1));
            }
        }
    }

    function testLambertW0WadMonotonicallyIncreasing2() public {
        // These are some problematic values gathered over the attempts.
        // Some might not be problematic now.
        _testLambertW0WadMonoAround(0x598cdf77327d789dc);
        _testLambertW0WadMonoAround(0x3c8d97dfe4afb1b05);
        _testLambertW0WadMonoAround(0x56a147b480c03cc22);
        _testLambertW0WadMonoAround(0x3136f439c231d0bb9);
        _testLambertW0WadMonoAround(0x2ae7cff17ef2469a1);
        _testLambertW0WadMonoAround(0x1de668fd7afcf61cc);
        _testLambertW0WadMonoAround(0x15024b2a35f2cdd95);
        _testLambertW0WadMonoAround(0x11a65ae94b59590f9);
        _testLambertW0WadMonoAround(0xf0c2c82174dffb7e);
        _testLambertW0WadMonoAround(0xed3e56938cb11626);
        _testLambertW0WadMonoAround(0xecf5c4e511142439);
        _testLambertW0WadMonoAround(0xc0755fa2b4033cb0);
        _testLambertW0WadMonoAround(0xa235db282ea4edc6);
        _testLambertW0WadMonoAround(0x9ff2ec5c26eec112);
        _testLambertW0WadMonoAround(0xa0c3c4e36f4415f1);
        _testLambertW0WadMonoAround(0x9b9f0e8d61287782);
        _testLambertW0WadMonoAround(0x7df719d1a4a7b8ad);
        _testLambertW0WadMonoAround(0x7c881679a1464d25);
        _testLambertW0WadMonoAround(0x7bec47487071495a);
        _testLambertW0WadMonoAround(0x7be31c75fc717f9f);
        _testLambertW0WadMonoAround(0x7bbb4e0716eeca53);
        _testLambertW0WadMonoAround(0x78e59d40a92b443b);
        _testLambertW0WadMonoAround(0x77658c4ad3af717d);
        _testLambertW0WadMonoAround(0x75ae9afa425919fe);
        _testLambertW0WadMonoAround(0x7526092d05bef41f);
        _testLambertW0WadMonoAround(0x52896fe82be03dfe);
        _testLambertW0WadMonoAround(0x4f05b0ddf3b71a19);
        _testLambertW0WadMonoAround(0x3094b0feb93943fd);
        _testLambertW0WadMonoAround(0x2ef215ae6701c40e);
        _testLambertW0WadMonoAround(0x2ebd1c82095d6a92);
        _testLambertW0WadMonoAround(0x2e520a4e670d52bb);
        _testLambertW0WadMonoAround(0xfc2f004412e5ce69);
        _testLambertW0WadMonoAround(0x158bc0b201103a7fc);
        _testLambertW0WadMonoAround(0x39280df60945c436b);
        _testLambertW0WadMonoAround(0x47256e5d374b35f74);
        _testLambertW0WadMonoAround(0x2b9568ffb08c155a4);
        _testLambertW0WadMonoAround(0x1b60b07806956f34d);
        _testLambertW0WadMonoAround(0x21902755d1eee824c);
        _testLambertW0WadMonoAround(0x6e15c8a6ee6e4fca4);
        _testLambertW0WadMonoAround(0x5b13067d92d8e49c6);
        _testLambertW0WadMonoAround(0x2826ebc1fce90cf6e);
        _testLambertW0WadMonoAround(0x215eb5aa1041510a4);
        _testLambertW0WadMonoAround(0x47b20347b57504c32);
        _testLambertW0WadMonoAround(0x75e8fd53f8c90f95a);
        _testLambertW0WadMonoAround(0x43e8d80f9af282627);
        _testLambertW0WadMonoAround(0x3cf555b5fd4f20615);
        _testLambertW0WadMonoAround(0xaff4b8b52f8355e6e);
        _testLambertW0WadMonoAround(0x529e89e77ae046255);
        _testLambertW0WadMonoAround(0x1f0289433f07cbf53b);
        _testLambertW0WadMonoAround(0xc1f6e56c2001d9432);
        _testLambertW0WadMonoAround(0x5e4117305c6e33ebc);
        _testLambertW0WadMonoAround(0x2b416472dce2ea26d);
        _testLambertW0WadMonoAround(0x71f55956ef3326067);
        _testLambertW0WadMonoAround(0x35d9d57c965eb82c6);
        _testLambertW0WadMonoAround(0x184f520f19335f25d);
        _testLambertW0WadMonoAround(0x3c4bb8f445abe21a7);
        _testLambertW0WadMonoAround(0x573e3b3e06e208201);
        _testLambertW0WadMonoAround(0x184f520f19335f25d);
        _testLambertW0WadMonoAround(0x573e3b3e06e208201);
        _testLambertW0WadMonoAround(0x61e511ba00db632a4);
        _testLambertW0WadMonoAround(0x12731b97bde57933d);
        _testLambertW0WadMonoAround(0x79c29b05cf39be374);
        _testLambertW0WadMonoAround(0x390fcd4186ac250b3);
        _testLambertW0WadMonoAround(0x69c74b5975fd4832a);
        _testLambertW0WadMonoAround(0x59db219a7048121bd);
        _testLambertW0WadMonoAround(0x28f2adc4fab331d251);
        _testLambertW0WadMonoAround(0x7be91527cc31769c);
        _testLambertW0WadMonoAround(0x2ef215ae6701c40f);
        _testLambertW0WadMonoAround(0x1240541334cfadd81);
        _testLambertW0WadMonoAround(0x2a79eccb3d5f4faaed);
        _testLambertW0WadMonoAround(0x7470d50c23bfd30e0);
        _testLambertW0WadMonoAround(0x313386f14a7f95af9);
        _testLambertW0WadMonoAround(0x2a60f3b64c57088e9);
        _testLambertW0WadMonoAround(0x381298f7aa53edfe0);
        _testLambertW0WadMonoAround(0x5cbfac5d7a1770806);
        _testLambertW0WadMonoAround(0x19e46d1b5e6aba57e);
        _testLambertW0WadMonoAround(0x19ff86906ae47c70a);
        _testLambertW0WadMonoAround(0x164684654d9ca54ea1);
        _testLambertW0WadMonoAround(0x99337fa75e803139);
        _testLambertW0WadMonoAround(0x6fa0a50fcb8a95b97e);
        _testLambertW0WadMonoAround(0xa117a195e06c3fd531);
        _testLambertW0WadMonoAround(0x305da7073093bd8a07);
        _testLambertW0WadMonoAround(0x98582b07fd3c6b64);
        _testLambertW0WadMonoAround(0x1e824d2a367d9ce65);
        _testLambertW0WadMonoAround(0x7bea796d633b386a);
        _testLambertW0WadMonoAround(0x2fff5c38c6b2a2cd);
        _testLambertW0WadMonoAround(0x198af4e7ffee1df7627);
        _testLambertW0WadMonoAround(0x8ea8a7b6f7c7424d8d);
        _testLambertW0WadMonoAround(0x11e504fa805e54e2ed8);
        _testLambertW0WadMonoAround(0x3e5f2a7801badcdabd);
        _testLambertW0WadMonoAround(0x1b7aaad69ac8770a3be);
        _testLambertW0WadMonoAround(0x658acb00d525f3d345);
        _testLambertW0WadMonoAround(0xd994d6447146880183f);
        _testLambertW0WadMonoAround(0x2e07a342d7b1bc1a5ae);
    }

    function testLambertW0WadMonoDebug() public {
        unchecked {
            for (int256 i = -9; i <= 9; ++i) {
                _testLambertW0WadMonoAround(0x2e07a342d7b1bc1a5ae + i);
            }
        }
    }

    function _testLambertW0WadMonoAround(int256 x) internal {
        emit LogInt("x", x);
        emit LogUint("log2(x)", FixedPointMathLib.log2(uint256(x)));
        testLambertW0WadMonotonicallyIncreasingAround(x);
    }

    function testLambertW0WadMonotonicallyIncreasingAround2(uint96 t) public {
        int256 x = int256(uint256(t));
        testLambertW0WadMonotonicallyIncreasingAround(x);
        if (t & 0xff == 0xab) {
            _testLambertW0WadMonoFocus(x, 0, 0x1ffffffffffff, 0xffffffffffffffffff);
            _testLambertW0WadMonoFocus(x, 1, 0x1fffffffffffff, 0xffffffffffffffffff);
            _testLambertW0WadMonoFocus(x, 2, 0xfffffffffffffff, 0xffffffffffffffffff);
            _testLambertW0WadMonoFocus(x, 3, 0xffffffffffffffff, 0xfffffffffffffffff);
            _testLambertW0WadMonoFocus(x, 4, 0xffffffffffffffff, 0xfffffffffffffffff);
            _testLambertW0WadMonoFocus(x, 5, 0xffffffffffffffff, 0xffffffffffffffffff);
            _testLambertW0WadMonoFocus(x, 6, 0xffffffffffffffff, 0xffffffffffffffffff);
            _testLambertW0WadMonoFocus(x, 7, 0xffffffffffffffff, 0xfffffffffffffffffff);
            _testLambertW0WadMonoFocus(x, 8, 0xffffffffffffffff, 0xfffffffffffffffffff);
            _testLambertW0WadMonoFocus(x, 9, 0xffffffffffffffff, 0xffffffffffffffffffff);
        }
    }

    function _testLambertW0WadMonoFocus(int256 t, int256 i, int256 low, int256 mask) internal {
        int256 x;
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, t)
            mstore(0x20, i)
            x := and(keccak256(0x00, 0x40), mask)
        }
        do {
            testLambertW0WadMonotonicallyIncreasingAround(x);
            x >>= 1;
        } while (x >= low);
    }

    function testLambertW0WadMonotonicallyIncreasingAround(int256 t) public {
        if (t < _LAMBERT_W0_MIN) t = _boundLambertW0WadInput(t);
        unchecked {
            int256 end = t + 2;
            for (int256 x = t - 2; x != end; ++x) {
                testLambertW0WadMonotonicallyIncreasing(x, x + 1);
            }
        }
    }

    function testLambertW0WadMonotonicallyIncreasing(int256 a, int256 b) public {
        if (a < _LAMBERT_W0_MIN) a = _boundLambertW0WadInput(a);
        if (b < _LAMBERT_W0_MIN) b = _boundLambertW0WadInput(b);
        if (a > b) {
            int256 t = b;
            b = a;
            a = t;
        }
        unchecked {
            uint256 gasBefore = gasleft();
            int256 w0a = FixedPointMathLib.lambertW0Wad(a);
            uint256 gasUsed = gasBefore - gasleft();
            int256 w0b = FixedPointMathLib.lambertW0Wad(b);
            bool success = w0a <= w0b;
            emit TestingLambertW0WadMonotonicallyIncreasing(a, b, w0a, w0b, success, gasUsed);
            if (!success) {
                emit LogUint("log2(a)", FixedPointMathLib.log2(uint256(a)));
                emit LogUint("log2(b)", FixedPointMathLib.log2(uint256(b)));
                emit LogUint("log2(w0a)", FixedPointMathLib.log2(uint256(w0a)));
                emit LogUint("log2(w0b)", FixedPointMathLib.log2(uint256(w0b)));
                assertTrue(success);
            }
        }
    }

    function _boundLambertW0WadInput(int256 x) internal pure returns (int256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := shr(1, shl(1, not(x)))
        }
    }

    function testMulWad() public {
        assertEq(FixedPointMathLib.mulWad(2.5e18, 0.5e18), 1.25e18);
        assertEq(FixedPointMathLib.mulWad(3e18, 1e18), 3e18);
        assertEq(FixedPointMathLib.mulWad(369, 271), 0);
    }

    function testMulWadEdgeCases() public {
        assertEq(FixedPointMathLib.mulWad(0, 1e18), 0);
        assertEq(FixedPointMathLib.mulWad(1e18, 0), 0);
        assertEq(FixedPointMathLib.mulWad(0, 0), 0);
    }

    function testSMulWad() public {
        assertEq(FixedPointMathLib.sMulWad(0, -2e18), 0);
        assertEq(FixedPointMathLib.sMulWad(1e18, -1), -1);
        assertEq(FixedPointMathLib.sMulWad(-0.5e18, 2e18), -1e18);
        assertEq(FixedPointMathLib.sMulWad(-0.5e18, -10e18), 5e18);
    }

    function testSMulWadOverflowTrickDifferential(int256 x, int256 y) public {
        unchecked {
            bool c;
            int256 z;
            /// @solidity memory-safe-assembly
            assembly {
                z := mul(x, y)
                c := iszero(gt(or(iszero(x), eq(sdiv(z, x), y)), lt(not(x), eq(y, shl(255, 1)))))
            }
            assertEq(c, !((x == 0 || z / x == y) && (x != -1 || y != type(int256).min)));
        }
    }

    function testSMulWadEdgeCases() public {
        assertEq(FixedPointMathLib.sMulWad(1e18, type(int256).max / 1e18), type(int256).max / 1e18);
        assertEq(FixedPointMathLib.sMulWad(-1e18, type(int256).min / 2e18), type(int256).max / 2e18);
        assertEq(FixedPointMathLib.sMulWad(0, 0), 0);
    }

    function testMulWadUp() public {
        assertEq(FixedPointMathLib.mulWadUp(2.5e18, 0.5e18), 1.25e18);
        assertEq(FixedPointMathLib.mulWadUp(3e18, 1e18), 3e18);
        assertEq(FixedPointMathLib.mulWadUp(369, 271), 1);
    }

    function testMulWadUpEdgeCases() public {
        assertEq(FixedPointMathLib.mulWadUp(0, 1e18), 0);
        assertEq(FixedPointMathLib.mulWadUp(1e18, 0), 0);
        assertEq(FixedPointMathLib.mulWadUp(0, 0), 0);
    }

    function testDivWad() public {
        assertEq(FixedPointMathLib.divWad(1.25e18, 0.5e18), 2.5e18);
        assertEq(FixedPointMathLib.divWad(3e18, 1e18), 3e18);
        assertEq(FixedPointMathLib.divWad(2, 100_000_000_000_000e18), 0);
    }

    function testDivWadEdgeCases() public {
        assertEq(FixedPointMathLib.divWad(0, 1e18), 0);
    }

    function testSDivWad() public {
        assertEq(FixedPointMathLib.sDivWad(1.25e18, -0.5e18), -2.5e18);
        assertEq(FixedPointMathLib.sDivWad(3e18, -1e18), -3e18);
        assertEq(FixedPointMathLib.sDivWad(type(int256).min / 1e18, type(int256).max), 0);
    }

    function testSDivWadEdgeCases() public {
        assertEq(FixedPointMathLib.sDivWad(0, 1e18), 0);
    }

    function testDivWadZeroDenominatorReverts() public {
        vm.expectRevert(FixedPointMathLib.DivWadFailed.selector);
        FixedPointMathLib.divWad(1e18, 0);
    }

    function testDivWadUp() public {
        assertEq(FixedPointMathLib.divWadUp(1.25e18, 0.5e18), 2.5e18);
        assertEq(FixedPointMathLib.divWadUp(3e18, 1e18), 3e18);
        assertEq(FixedPointMathLib.divWadUp(2, 100_000_000_000_000e18), 1);
        unchecked {
            for (uint256 i; i < 10; ++i) {
                assertEq(FixedPointMathLib.divWadUp(2, 100_000_000_000_000e18), 1);
            }
        }
    }

    function testDivWadUpEdgeCases() public {
        assertEq(FixedPointMathLib.divWadUp(0, 1e18), 0);
    }

    function testDivWadUpZeroDenominatorReverts() public {
        vm.expectRevert(FixedPointMathLib.DivWadFailed.selector);
        FixedPointMathLib.divWadUp(1e18, 0);
    }

    function testMulDiv() public {
        assertEq(FixedPointMathLib.mulDiv(2.5e27, 0.5e27, 1e27), 1.25e27);
        assertEq(FixedPointMathLib.mulDiv(2.5e18, 0.5e18, 1e18), 1.25e18);
        assertEq(FixedPointMathLib.mulDiv(2.5e8, 0.5e8, 1e8), 1.25e8);
        assertEq(FixedPointMathLib.mulDiv(369, 271, 1e2), 999);

        assertEq(FixedPointMathLib.mulDiv(1e27, 1e27, 2e27), 0.5e27);
        assertEq(FixedPointMathLib.mulDiv(1e18, 1e18, 2e18), 0.5e18);
        assertEq(FixedPointMathLib.mulDiv(1e8, 1e8, 2e8), 0.5e8);

        assertEq(FixedPointMathLib.mulDiv(2e27, 3e27, 2e27), 3e27);
        assertEq(FixedPointMathLib.mulDiv(3e18, 2e18, 3e18), 2e18);
        assertEq(FixedPointMathLib.mulDiv(2e8, 3e8, 2e8), 3e8);
    }

    function testMulDivEdgeCases() public {
        assertEq(FixedPointMathLib.mulDiv(0, 1e18, 1e18), 0);
        assertEq(FixedPointMathLib.mulDiv(1e18, 0, 1e18), 0);
        assertEq(FixedPointMathLib.mulDiv(0, 0, 1e18), 0);
    }

    function testMulDivZeroDenominatorReverts() public {
        vm.expectRevert(FixedPointMathLib.MulDivFailed.selector);
        FixedPointMathLib.mulDiv(1e18, 1e18, 0);
    }

    function testMulDivUp() public {
        assertEq(FixedPointMathLib.mulDivUp(2.5e27, 0.5e27, 1e27), 1.25e27);
        assertEq(FixedPointMathLib.mulDivUp(2.5e18, 0.5e18, 1e18), 1.25e18);
        assertEq(FixedPointMathLib.mulDivUp(2.5e8, 0.5e8, 1e8), 1.25e8);
        assertEq(FixedPointMathLib.mulDivUp(369, 271, 1e2), 1000);

        assertEq(FixedPointMathLib.mulDivUp(1e27, 1e27, 2e27), 0.5e27);
        assertEq(FixedPointMathLib.mulDivUp(1e18, 1e18, 2e18), 0.5e18);
        assertEq(FixedPointMathLib.mulDivUp(1e8, 1e8, 2e8), 0.5e8);

        assertEq(FixedPointMathLib.mulDivUp(2e27, 3e27, 2e27), 3e27);
        assertEq(FixedPointMathLib.mulDivUp(3e18, 2e18, 3e18), 2e18);
        assertEq(FixedPointMathLib.mulDivUp(2e8, 3e8, 2e8), 3e8);
    }

    function testMulDivUpEdgeCases() public {
        assertEq(FixedPointMathLib.mulDivUp(0, 1e18, 1e18), 0);
        assertEq(FixedPointMathLib.mulDivUp(1e18, 0, 1e18), 0);
        assertEq(FixedPointMathLib.mulDivUp(0, 0, 1e18), 0);
    }

    function testMulDivUpZeroDenominator() public {
        vm.expectRevert(FixedPointMathLib.MulDivFailed.selector);
        FixedPointMathLib.mulDivUp(1e18, 1e18, 0);
    }

    function testLnWad() public {
        assertEq(FixedPointMathLib.lnWad(1e18), 0);

        // Actual: 999999999999999999.8674576…
        assertEq(FixedPointMathLib.lnWad(2_718_281_828_459_045_235), 999_999_999_999_999_999);

        // Actual: 2461607324344817917.963296…
        assertEq(FixedPointMathLib.lnWad(11_723_640_096_265_400_935), 2_461_607_324_344_817_918);
    }

    function testLnWadSmall() public {
        // Actual: -41446531673892822312.3238461…
        assertEq(FixedPointMathLib.lnWad(1), -41_446_531_673_892_822_313);

        // Actual: -37708862055609454006.40601608…
        assertEq(FixedPointMathLib.lnWad(42), -37_708_862_055_609_454_007);

        // Actual: -32236191301916639576.251880365581…
        assertEq(FixedPointMathLib.lnWad(1e4), -32_236_191_301_916_639_577);

        // Actual: -20723265836946411156.161923092…
        assertEq(FixedPointMathLib.lnWad(1e9), -20_723_265_836_946_411_157);
    }

    function testLnWadBig() public {
        // Actual: 135305999368893231589.070344787…
        assertEq(FixedPointMathLib.lnWad(2 ** 255 - 1), 135_305_999_368_893_231_589);

        // Actual: 76388489021297880288.605614463571…
        assertEq(FixedPointMathLib.lnWad(2 ** 170), 76_388_489_021_297_880_288);

        // Actual: 47276307437780177293.081865…
        assertEq(FixedPointMathLib.lnWad(2 ** 128), 47_276_307_437_780_177_293);
    }

    function testLnWadNegativeReverts() public {
        vm.expectRevert(FixedPointMathLib.LnWadUndefined.selector);
        FixedPointMathLib.lnWad(-1);
        FixedPointMathLib.lnWad(-2 ** 255);
    }

    function testLnWadOverflowReverts() public {
        vm.expectRevert(FixedPointMathLib.LnWadUndefined.selector);
        FixedPointMathLib.lnWad(0);
    }

    function testRPow() public {
        assertEq(FixedPointMathLib.rpow(0, 0, 0), 0);
        assertEq(FixedPointMathLib.rpow(1, 0, 0), 0);
        assertEq(FixedPointMathLib.rpow(0, 1, 0), 0);
        assertEq(FixedPointMathLib.rpow(0, 0, 1), 1);
        assertEq(FixedPointMathLib.rpow(1, 1, 0), 1);
        assertEq(FixedPointMathLib.rpow(1, 1, 1), 1);
        assertEq(FixedPointMathLib.rpow(2e27, 0, 1e27), 1e27);
        assertEq(FixedPointMathLib.rpow(2e27, 2, 1e27), 4e27);
        assertEq(FixedPointMathLib.rpow(2e18, 2, 1e18), 4e18);
        assertEq(FixedPointMathLib.rpow(2e8, 2, 1e8), 4e8);
        assertEq(FixedPointMathLib.rpow(8, 3, 1), 512);
    }

    function testRPowOverflowReverts() public {
        vm.expectRevert(FixedPointMathLib.RPowOverflow.selector);
        FixedPointMathLib.rpow(2, type(uint128).max, 1);
        FixedPointMathLib.rpow(type(uint128).max, 3, 1);
    }

    function testSqrt() public {
        assertEq(FixedPointMathLib.sqrt(0), 0);
        assertEq(FixedPointMathLib.sqrt(1), 1);
        assertEq(FixedPointMathLib.sqrt(2704), 52);
        assertEq(FixedPointMathLib.sqrt(110_889), 333);
        assertEq(FixedPointMathLib.sqrt(32_239_684), 5678);
        unchecked {
            for (uint256 i = 100; i < 200; ++i) {
                assertEq(FixedPointMathLib.sqrt(i * i), i);
            }
        }
    }

    function testSqrtWad() public {
        assertEq(FixedPointMathLib.sqrtWad(0), 0);
        assertEq(FixedPointMathLib.sqrtWad(1), 10 ** 9);
        assertEq(FixedPointMathLib.sqrtWad(2), 1_414_213_562);
        assertEq(FixedPointMathLib.sqrtWad(4), 2_000_000_000);
        assertEq(FixedPointMathLib.sqrtWad(8), 2_828_427_124);
        assertEq(FixedPointMathLib.sqrtWad(16), 4_000_000_000);
        assertEq(FixedPointMathLib.sqrtWad(32), 5_656_854_249);
        assertEq(FixedPointMathLib.sqrtWad(64), 8_000_000_000);
        assertEq(FixedPointMathLib.sqrtWad(10 ** 18), 10 ** 18);
        assertEq(FixedPointMathLib.sqrtWad(4 * 10 ** 18), 2 * 10 ** 18);
        assertEq(FixedPointMathLib.sqrtWad(type(uint8).max), 15_968_719_422);
        assertEq(FixedPointMathLib.sqrtWad(type(uint16).max), 255_998_046_867);
        assertEq(FixedPointMathLib.sqrtWad(type(uint32).max), 65_535_999_992_370);
        assertEq(FixedPointMathLib.sqrtWad(type(uint64).max), 4_294_967_295_999_999_999);
        assertEq(FixedPointMathLib.sqrtWad(type(uint128).max), 18_446_744_073_709_551_615_999_999_999);
        assertEq(
            FixedPointMathLib.sqrtWad(type(uint256).max),
            340_282_366_920_938_463_463_374_607_431_768_211_455_000_000_000
        );
    }

    function testCbrt() public {
        assertEq(FixedPointMathLib.cbrt(0), 0);
        assertEq(FixedPointMathLib.cbrt(1), 1);
        assertEq(FixedPointMathLib.cbrt(2), 1);
        assertEq(FixedPointMathLib.cbrt(3), 1);
        assertEq(FixedPointMathLib.cbrt(9), 2);
        assertEq(FixedPointMathLib.cbrt(27), 3);
        assertEq(FixedPointMathLib.cbrt(80), 4);
        assertEq(FixedPointMathLib.cbrt(81), 4);
        assertEq(FixedPointMathLib.cbrt(10 ** 18), 10 ** 6);
        assertEq(FixedPointMathLib.cbrt(8 * 10 ** 18), 2 * 10 ** 6);
        assertEq(FixedPointMathLib.cbrt(9 * 10 ** 18), 2_080_083);
        assertEq(FixedPointMathLib.cbrt(type(uint8).max), 6);
        assertEq(FixedPointMathLib.cbrt(type(uint16).max), 40);
        assertEq(FixedPointMathLib.cbrt(type(uint32).max), 1625);
        assertEq(FixedPointMathLib.cbrt(type(uint64).max), 2_642_245);
        assertEq(FixedPointMathLib.cbrt(type(uint128).max), 6_981_463_658_331);
        assertEq(FixedPointMathLib.cbrt(type(uint256).max), 48_740_834_812_604_276_470_692_694);
    }

    function testCbrtWad() public {
        assertEq(FixedPointMathLib.cbrtWad(0), 0);
        assertEq(FixedPointMathLib.cbrtWad(1), 10 ** 12);
        assertEq(FixedPointMathLib.cbrtWad(2), 1_259_921_049_894);
        assertEq(FixedPointMathLib.cbrtWad(3), 1_442_249_570_307);
        assertEq(FixedPointMathLib.cbrtWad(9), 2_080_083_823_051);
        assertEq(FixedPointMathLib.cbrtWad(27), 3_000_000_000_000);
        assertEq(FixedPointMathLib.cbrtWad(80), 4_308_869_380_063);
        assertEq(FixedPointMathLib.cbrtWad(81), 4_326_748_710_922);
        assertEq(FixedPointMathLib.cbrtWad(10 ** 18), 10 ** 18);
        assertEq(FixedPointMathLib.cbrtWad(8 * 10 ** 18), 2 * 10 ** 18);
        assertEq(FixedPointMathLib.cbrtWad(9 * 10 ** 18), 2_080_083_823_051_904_114);
        assertEq(FixedPointMathLib.cbrtWad(type(uint8).max), 6_341_325_705_384);
        assertEq(FixedPointMathLib.cbrtWad(type(uint16).max), 40_317_268_530_317);
        assertEq(FixedPointMathLib.cbrtWad(type(uint32).max), 1_625_498_677_089_280);
        assertEq(FixedPointMathLib.cbrtWad(type(uint64).max), 2_642_245_949_629_133_047);
        assertEq(FixedPointMathLib.cbrtWad(type(uint128).max), 6_981_463_658_331_559_092_288_464);
        assertEq(FixedPointMathLib.cbrtWad(type(uint256).max), 48_740_834_812_604_276_470_692_694_000_000_000_000);
    }

    function testLog2() public {
        assertEq(FixedPointMathLib.log2(0), 0);
        assertEq(FixedPointMathLib.log2(2), 1);
        assertEq(FixedPointMathLib.log2(4), 2);
        assertEq(FixedPointMathLib.log2(1024), 10);
        assertEq(FixedPointMathLib.log2(1_048_576), 20);
        assertEq(FixedPointMathLib.log2(1_073_741_824), 30);
        for (uint256 i = 1; i < 255; i++) {
            assertEq(FixedPointMathLib.log2((1 << i) - 1), i - 1);
            assertEq(FixedPointMathLib.log2((1 << i)), i);
            assertEq(FixedPointMathLib.log2((1 << i) + 1), i);
        }
    }

    function testLog2Differential(uint256 x) public {
        assertEq(FixedPointMathLib.log2(x), _log2Original(x));
    }

    function _log2Original(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    function testLog2Up() public {
        assertEq(FixedPointMathLib.log2Up(0), 0);
        assertEq(FixedPointMathLib.log2Up(1), 0);
        assertEq(FixedPointMathLib.log2Up(2), 1);
        assertEq(FixedPointMathLib.log2Up(2 + 1), 2);
        assertEq(FixedPointMathLib.log2Up(4), 2);
        assertEq(FixedPointMathLib.log2Up(4 + 1), 3);
        assertEq(FixedPointMathLib.log2Up(4 + 2), 3);
        assertEq(FixedPointMathLib.log2Up(1024), 10);
        assertEq(FixedPointMathLib.log2Up(1024 + 1), 11);
        assertEq(FixedPointMathLib.log2Up(1_048_576), 20);
        assertEq(FixedPointMathLib.log2Up(1_048_576 + 1), 21);
        assertEq(FixedPointMathLib.log2Up(1_073_741_824), 30);
        assertEq(FixedPointMathLib.log2Up(1_073_741_824 + 1), 31);
        for (uint256 i = 2; i < 255; i++) {
            assertEq(FixedPointMathLib.log2Up((1 << i) - 1), i);
            assertEq(FixedPointMathLib.log2Up((1 << i)), i);
            assertEq(FixedPointMathLib.log2Up((1 << i) + 1), i + 1);
        }
    }

    function testAvg() public {
        assertEq(FixedPointMathLib.avg(uint256(5), uint256(6)), uint256(5));
        assertEq(FixedPointMathLib.avg(uint256(0), uint256(1)), uint256(0));
        assertEq(FixedPointMathLib.avg(uint256(45_645_465), uint256(4_846_513)), uint256(25_245_989));
    }

    function testAvgSigned() public {
        assertEq(FixedPointMathLib.avg(int256(5), int256(6)), int256(5));
        assertEq(FixedPointMathLib.avg(int256(0), int256(1)), int256(0));
        assertEq(FixedPointMathLib.avg(int256(45_645_465), int256(4_846_513)), int256(25_245_989));

        assertEq(FixedPointMathLib.avg(int256(5), int256(-6)), int256(-1));
        assertEq(FixedPointMathLib.avg(int256(0), int256(-1)), int256(-1));
        assertEq(FixedPointMathLib.avg(int256(45_645_465), int256(-4_846_513)), int256(20_399_476));
    }

    function testAvgEdgeCase() public {
        assertEq(FixedPointMathLib.avg(uint256(2 ** 256 - 1), uint256(1)), uint256(2 ** 255));
        assertEq(FixedPointMathLib.avg(uint256(2 ** 256 - 1), uint256(10)), uint256(2 ** 255 + 4));
        assertEq(FixedPointMathLib.avg(uint256(2 ** 256 - 1), uint256(2 ** 256 - 1)), uint256(2 ** 256 - 1));
    }

    function testAbs() public {
        assertEq(FixedPointMathLib.abs(0), 0);
        assertEq(FixedPointMathLib.abs(-5), 5);
        assertEq(FixedPointMathLib.abs(5), 5);
        assertEq(FixedPointMathLib.abs(-1_155_656_654), 1_155_656_654);
        assertEq(FixedPointMathLib.abs(621_356_166_516_546_561_651), 621_356_166_516_546_561_651);
    }

    function testDist() public {
        assertEq(FixedPointMathLib.dist(0, 0), 0);
        assertEq(FixedPointMathLib.dist(-5, -4), 1);
        assertEq(FixedPointMathLib.dist(5, 46), 41);
        assertEq(FixedPointMathLib.dist(46, 5), 41);
        assertEq(FixedPointMathLib.dist(-1_155_656_654, 6_544_844), 1_162_201_498);
        assertEq(FixedPointMathLib.dist(-848_877, -8_447_631_456), 8_446_782_579);
    }

    function testDistEdgeCases() public {
        assertEq(FixedPointMathLib.dist(type(int256).min, type(int256).max), type(uint256).max);
        assertEq(
            FixedPointMathLib.dist(type(int256).min, 0),
            0x8000000000000000000000000000000000000000000000000000000000000000
        );
        assertEq(
            FixedPointMathLib.dist(type(int256).max, 5),
            0x7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffa
        );
        assertEq(
            FixedPointMathLib.dist(type(int256).min, -5),
            0x7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb
        );
    }

    function testAbsEdgeCases() public {
        assertEq(FixedPointMathLib.abs(-(2 ** 255 - 1)), (2 ** 255 - 1));
        assertEq(FixedPointMathLib.abs((2 ** 255 - 1)), (2 ** 255 - 1));
    }

    function testGcd() public {
        assertEq(FixedPointMathLib.gcd(0, 0), 0);
        assertEq(FixedPointMathLib.gcd(85, 0), 85);
        assertEq(FixedPointMathLib.gcd(0, 2), 2);
        assertEq(FixedPointMathLib.gcd(56, 45), 1);
        assertEq(FixedPointMathLib.gcd(12, 28), 4);
        assertEq(FixedPointMathLib.gcd(12, 1), 1);
        assertEq(FixedPointMathLib.gcd(486_516_589_451_122, 48_656), 2);
        assertEq(FixedPointMathLib.gcd(2 ** 254 - 4, 2 ** 128 - 1), 15);
        assertEq(FixedPointMathLib.gcd(3, 26_017_198_113_384_995_722_614_372_765_093_167_890), 1);
        unchecked {
            for (uint256 i = 2; i < 10; ++i) {
                assertEq(FixedPointMathLib.gcd(31 * (1 << i), 31), 31);
            }
        }
    }

    function testFullMulDiv() public {
        assertEq(FixedPointMathLib.fullMulDiv(0, 0, 1), 0);
        assertEq(FixedPointMathLib.fullMulDiv(4, 4, 2), 8);
        assertEq(FixedPointMathLib.fullMulDiv(2 ** 200, 2 ** 200, 2 ** 200), 2 ** 200);
    }

    function testFullMulDivUpRevertsIfRoundedUpResultOverflowsCase1() public {
        vm.expectRevert(FixedPointMathLib.FullMulDivFailed.selector);
        FixedPointMathLib.fullMulDivUp(
            535_006_138_814_359, 432_862_656_469_423_142_931_042_426_214_547_535_783_388_063_929_571_229_938_474_969, 2
        );
    }

    function testFullMulDivUpRevertsIfRoundedUpResultOverflowsCase2() public {
        vm.expectRevert(FixedPointMathLib.FullMulDivFailed.selector);
        FixedPointMathLib.fullMulDivUp(
            115_792_089_237_316_195_423_570_985_008_687_907_853_269_984_659_341_747_863_450_311_749_907_997_002_549,
            115_792_089_237_316_195_423_570_985_008_687_907_853_269_984_659_341_747_863_450_311_749_907_997_002_550,
            115_792_089_237_316_195_423_570_985_008_687_907_853_269_984_653_042_931_687_443_039_491_902_864_365_164
        );
    }

    function testFullMulDiv(uint256 a, uint256 b, uint256 d) public returns (uint256 result) {
        if (d == 0) {
            vm.expectRevert(FixedPointMathLib.FullMulDivFailed.selector);
            FixedPointMathLib.fullMulDiv(a, b, d);
            return 0;
        }

        // Compute a * b in Chinese Remainder Basis
        uint256 expectedA;
        uint256 expectedB;
        unchecked {
            expectedA = a * b;
            expectedB = mulmod(a, b, 2 ** 256 - 1);
        }

        // Construct a * b
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        /// @solidity memory-safe-assembly
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }
        if (prod1 >= d) {
            vm.expectRevert(FixedPointMathLib.FullMulDivFailed.selector);
            FixedPointMathLib.fullMulDiv(a, b, d);
            return 0;
        }

        uint256 q = FixedPointMathLib.fullMulDiv(a, b, d);
        uint256 r = mulmod(a, b, d);

        // Compute q * d + r in Chinese Remainder Basis
        uint256 actualA;
        uint256 actualB;
        unchecked {
            actualA = q * d + r;
            actualB = addmod(mulmod(q, d, 2 ** 256 - 1), r, 2 ** 256 - 1);
        }

        assertEq(actualA, expectedA);
        assertEq(actualB, expectedB);
        return q;
    }

    function testFullMulDivUp(uint256 a, uint256 b, uint256 d) public {
        uint256 fullMulDivResult = testFullMulDiv(a, b, d);
        if (fullMulDivResult != 0) {
            uint256 expectedResult = fullMulDivResult;
            if (mulmod(a, b, d) > 0) {
                if (!(fullMulDivResult < type(uint256).max)) {
                    vm.expectRevert(FixedPointMathLib.FullMulDivFailed.selector);
                    FixedPointMathLib.fullMulDivUp(a, b, d);
                    return;
                }
                expectedResult++;
            }
            assertEq(FixedPointMathLib.fullMulDivUp(a, b, d), expectedResult);
        }
    }

    function testMulWad(uint256 x, uint256 y) public {
        // Ignore cases where x * y overflows.
        unchecked {
            if (x != 0 && (x * y) / x != y) return;
        }

        uint256 result = FixedPointMathLib.mulWad(x, y);
        assertEq(result, (x * y) / 1e18);
        assertEq(FixedPointMathLib.rawMulWad(x, y), result);
    }

    function testSMulWad(int256 x, int256 y) public {
        // Ignore cases where x * y overflows.
        unchecked {
            if ((x != 0 && (x * y) / x != y) || (x == -1 && y == type(int256).min)) return;
        }

        int256 result = FixedPointMathLib.sMulWad(x, y);
        assertEq(result, int256((x * y) / 1e18));
        assertEq(FixedPointMathLib.rawSMulWad(x, y), result);
    }

    function testMulWadOverflowReverts(uint256 x, uint256 y) public {
        unchecked {
            vm.assume(x != 0 && (x * y) / x != y);
        }
        vm.expectRevert(FixedPointMathLib.MulWadFailed.selector);
        FixedPointMathLib.mulWad(x, y);
    }

    function testSMulWadOverflowRevertsOnCondition1(int256 x, int256 y) public {
        unchecked {
            vm.assume(x != 0 && (x * y) / x != y);
        }
        vm.expectRevert(FixedPointMathLib.SMulWadFailed.selector);
        FixedPointMathLib.sMulWad(x, y);
    }

    function testSMulWadOverflowRevertsOnCondition2(int256 x) public {
        vm.assume(x < 0);
        vm.expectRevert(FixedPointMathLib.SMulWadFailed.selector);
        FixedPointMathLib.sMulWad(x, type(int256).min);
    }

    function testMulWadUp(uint256 x, uint256 y) public {
        // Ignore cases where x * y overflows.
        unchecked {
            if (x != 0 && (x * y) / x != y) return;
        }

        assertEq(FixedPointMathLib.mulWadUp(x, y), x * y == 0 ? 0 : (x * y - 1) / 1e18 + 1);
    }

    function testMulWadUpOverflowReverts(uint256 x, uint256 y) public {
        unchecked {
            vm.assume(x != 0 && !((x * y) / x == y));
        }
        vm.expectRevert(FixedPointMathLib.MulWadFailed.selector);
        FixedPointMathLib.mulWadUp(x, y);
    }

    function testDivWad(uint256 x, uint256 y) public {
        // Ignore cases where x * WAD overflows or y is 0.
        unchecked {
            if (y == 0 || (x != 0 && (x * 1e18) / 1e18 != x)) return;
        }

        uint256 result = FixedPointMathLib.divWad(x, y);
        assertEq(result, (x * 1e18) / y);
        assertEq(FixedPointMathLib.rawDivWad(x, y), result);
    }

    function testSDivWad(int256 x, int256 y) public {
        // Ignore cases where x * WAD overflows or y is 0.
        unchecked {
            if (y == 0 || (x != 0 && (x * 1e18) / 1e18 != x)) return;
        }

        int256 result = FixedPointMathLib.sDivWad(x, y);
        assertEq(result, int256((x * 1e18) / y));
        assertEq(FixedPointMathLib.rawSDivWad(x, y), result);
    }

    function testDivWadOverflowReverts(uint256 x, uint256 y) public {
        unchecked {
            vm.assume(y != 0 && (x * 1e18) / 1e18 != x);
        }
        vm.expectRevert(FixedPointMathLib.DivWadFailed.selector);
        FixedPointMathLib.divWad(x, y);
    }

    function testSDivWadOverflowReverts(int256 x, int256 y) public {
        unchecked {
            vm.assume(y != 0 && (x * 1e18) / 1e18 != x);
        }
        vm.expectRevert(FixedPointMathLib.SDivWadFailed.selector);
        FixedPointMathLib.sDivWad(x, y);
    }

    function testDivWadZeroDenominatorReverts(uint256 x) public {
        vm.expectRevert(FixedPointMathLib.DivWadFailed.selector);
        FixedPointMathLib.divWad(x, 0);
    }

    function testSDivWadZeroDenominatorReverts(int256 x) public {
        vm.expectRevert(FixedPointMathLib.SDivWadFailed.selector);
        FixedPointMathLib.sDivWad(x, 0);
    }

    function testDivWadUp(uint256 x, uint256 y) public {
        // Ignore cases where x * WAD overflows or y is 0.
        unchecked {
            if (y == 0 || (x != 0 && (x * 1e18) / 1e18 != x)) return;
        }

        assertEq(FixedPointMathLib.divWadUp(x, y), x == 0 ? 0 : (x * 1e18 - 1) / y + 1);
    }

    function testDivWadUpOverflowReverts(uint256 x, uint256 y) public {
        unchecked {
            vm.assume(y != 0 && (x * 1e18) / 1e18 != x);
        }
        vm.expectRevert(FixedPointMathLib.DivWadFailed.selector);
        FixedPointMathLib.divWadUp(x, y);
    }

    function testDivWadUpZeroDenominatorReverts(uint256 x) public {
        vm.expectRevert(FixedPointMathLib.DivWadFailed.selector);
        FixedPointMathLib.divWadUp(x, 0);
    }

    function testMulDiv(uint256 x, uint256 y, uint256 denominator) public {
        // Ignore cases where x * y overflows or denominator is 0.
        unchecked {
            if (denominator == 0 || (x != 0 && (x * y) / x != y)) return;
        }

        assertEq(FixedPointMathLib.mulDiv(x, y, denominator), (x * y) / denominator);
    }

    function testMulDivOverflowReverts(uint256 x, uint256 y, uint256 denominator) public {
        unchecked {
            vm.assume(denominator != 0 && x != 0 && (x * y) / x != y);
        }
        vm.expectRevert(FixedPointMathLib.MulDivFailed.selector);
        FixedPointMathLib.mulDiv(x, y, denominator);
    }

    function testMulDivZeroDenominatorReverts(uint256 x, uint256 y) public {
        vm.expectRevert(FixedPointMathLib.MulDivFailed.selector);
        FixedPointMathLib.mulDiv(x, y, 0);
    }

    function testMulDivUp(uint256 x, uint256 y, uint256 denominator) public {
        // Ignore cases where x * y overflows or denominator is 0.
        unchecked {
            if (denominator == 0 || (x != 0 && (x * y) / x != y)) return;
        }

        assertEq(FixedPointMathLib.mulDivUp(x, y, denominator), x * y == 0 ? 0 : (x * y - 1) / denominator + 1);
    }

    function testMulDivUpOverflowReverts(uint256 x, uint256 y, uint256 denominator) public {
        unchecked {
            vm.assume(denominator != 0 && x != 0 && (x * y) / x != y);
        }
        vm.expectRevert(FixedPointMathLib.MulDivFailed.selector);
        FixedPointMathLib.mulDivUp(x, y, denominator);
    }

    function testMulDivUpZeroDenominatorReverts(uint256 x, uint256 y) public {
        vm.expectRevert(FixedPointMathLib.MulDivFailed.selector);
        FixedPointMathLib.mulDivUp(x, y, 0);
    }

    function testCbrt(uint256 x) public {
        uint256 root = FixedPointMathLib.cbrt(x);
        uint256 next = root + 1;

        // Ignore cases where `next * next * next` or `next * next` overflows.
        unchecked {
            if (next * next * next < next * next) return;
            if (next * next < next) return;
        }

        assertTrue(root * root * root <= x && next * next * next > x);
    }

    function testCbrtWad(uint256 x) public {
        uint256 result = FixedPointMathLib.cbrtWad(x);
        uint256 floor = FixedPointMathLib.cbrt(x);
        assertTrue(result >= floor * 10 ** 12 && result <= (floor + 1) * 10 ** 12);
        assertEq(result / 10 ** 12, floor);
    }

    function testCbrtBack(uint256 x) public {
        unchecked {
            x = _bound(x, 0, 48_740_834_812_604_276_470_692_694);
            while (x != 0) {
                assertEq(FixedPointMathLib.cbrt(x * x * x), x);
                x >>= 1;
            }
        }
    }

    function testSqrt(uint256 x) public {
        uint256 root = FixedPointMathLib.sqrt(x);
        uint256 next = root + 1;

        // Ignore cases where `next * next` overflows.
        unchecked {
            if (next * next < next) return;
        }

        assertTrue(root * root <= x && next * next > x);
    }

    function testSqrtWad(uint256 x) public {
        uint256 result = FixedPointMathLib.sqrtWad(x);
        uint256 floor = FixedPointMathLib.sqrt(x);
        assertTrue(result >= floor * 10 ** 9 && result <= (floor + 1) * 10 ** 9);
        assertEq(result / 10 ** 9, floor);
    }

    function testSqrtBack(uint256 x) public {
        unchecked {
            x >>= 128;
            while (x != 0) {
                assertEq(FixedPointMathLib.sqrt(x * x), x);
                x >>= 1;
            }
        }
    }

    function testSqrtHashed(uint256 x) public {
        testSqrtBack(uint256(keccak256(abi.encode(x))));
    }

    function testSqrtHashedSingle() public {
        testSqrtHashed(123);
    }

    function testMin(uint256 x, uint256 y) public {
        uint256 z = x < y ? x : y;
        assertEq(FixedPointMathLib.min(x, y), z);
    }

    function testMinBrutalized(uint256 x, uint256 y) public {
        uint32 xCasted;
        uint32 yCasted;
        /// @solidity memory-safe-assembly
        assembly {
            xCasted := x
            yCasted := y
        }
        uint256 expected = xCasted < yCasted ? xCasted : yCasted;
        assertEq(FixedPointMathLib.min(xCasted, yCasted), expected);
        assertEq(FixedPointMathLib.min(uint32(x), uint32(y)), expected);
        expected = uint32(x) < uint32(y) ? uint32(x) : uint32(y);
        assertEq(FixedPointMathLib.min(xCasted, yCasted), expected);
    }

    function testMinSigned(int256 x, int256 y) public {
        int256 z = x < y ? x : y;
        assertEq(FixedPointMathLib.min(x, y), z);
    }

    function testMax(uint256 x, uint256 y) public {
        uint256 z = x > y ? x : y;
        assertEq(FixedPointMathLib.max(x, y), z);
    }

    function testMaxSigned(int256 x, int256 y) public {
        int256 z = x > y ? x : y;
        assertEq(FixedPointMathLib.max(x, y), z);
    }

    function testMaxCasted(uint32 x, uint32 y, uint256 brutalizer) public {
        uint32 z = x > y ? x : y;
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, brutalizer)
            mstore(0x20, 1)
            x := or(shl(32, keccak256(0x00, 0x40)), x)
            mstore(0x20, 2)
            y := or(shl(32, keccak256(0x00, 0x40)), y)
        }
        assertTrue(FixedPointMathLib.max(x, y) == z);
    }

    function testZeroFloorSub(uint256 x, uint256 y) public {
        uint256 z = x > y ? x - y : 0;
        assertEq(FixedPointMathLib.zeroFloorSub(x, y), z);
    }

    function testZeroFloorSubCasted(uint32 x, uint32 y, uint256 brutalizer) public {
        uint256 z = x > y ? x - y : 0;
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, brutalizer)
            mstore(0x20, 1)
            x := or(shl(32, keccak256(0x00, 0x40)), x)
            mstore(0x20, 2)
            y := or(shl(32, keccak256(0x00, 0x40)), y)
        }
        assertTrue(FixedPointMathLib.zeroFloorSub(x, y) == z);
    }

    function testDist(int256 x, int256 y) public {
        uint256 z;
        unchecked {
            if (x > y) {
                z = uint256(x - y);
            } else {
                z = uint256(y - x);
            }
        }
        assertEq(FixedPointMathLib.dist(x, y), z);
    }

    function testAbs(int256 x) public {
        uint256 z = uint256(x);
        if (x < 0) {
            if (x == type(int256).min) {
                z = uint256(type(int256).max) + 1;
            } else {
                z = uint256(-x);
            }
        }
        assertEq(FixedPointMathLib.abs(x), z);
    }

    function testGcd(uint256 x, uint256 y) public {
        assertEq(FixedPointMathLib.gcd(x, y), _gcd(x, y));
    }

    function testClamp(uint256 x, uint256 minValue, uint256 maxValue) public {
        uint256 clamped = x;
        if (clamped < minValue) {
            clamped = minValue;
        }
        if (clamped > maxValue) {
            clamped = maxValue;
        }
        assertEq(FixedPointMathLib.clamp(x, minValue, maxValue), clamped);
    }

    function testClampSigned(int256 x, int256 minValue, int256 maxValue) public {
        int256 clamped = x;
        if (clamped < minValue) {
            clamped = minValue;
        }
        if (clamped > maxValue) {
            clamped = maxValue;
        }
        assertEq(FixedPointMathLib.clamp(x, minValue, maxValue), clamped);
    }

    function testFactorial() public {
        uint256 result = 1;
        assertEq(FixedPointMathLib.factorial(0), result);
        unchecked {
            for (uint256 i = 1; i != 58; ++i) {
                result = result * i;
                assertEq(FixedPointMathLib.factorial(i), result);
            }
        }
        vm.expectRevert(FixedPointMathLib.FactorialOverflow.selector);
        FixedPointMathLib.factorial(58);
    }

    function testFactorialOriginal() public {
        uint256 result = 1;
        assertEq(_factorialOriginal(0), result);
        unchecked {
            for (uint256 i = 1; i != 58; ++i) {
                result = result * i;
                assertEq(_factorialOriginal(i), result);
            }
        }
    }

    function _factorialOriginal(uint256 x) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := 1
            for { } x { } {
                result := mul(result, x)
                x := sub(x, 1)
            }
        }
    }

    function _gcd(uint256 x, uint256 y) internal pure returns (uint256 result) {
        if (y == 0) {
            return x;
        } else {
            return _gcd(y, x % y);
        }
    }

    function testRawAdd(uint256 x, uint256 y) public {
        uint256 z;
        /// @solidity memory-safe-assembly
        assembly {
            z := add(x, y)
        }
        assertEq(FixedPointMathLib.rawAdd(x, y), z);
    }

    function testRawAdd(int256 x, int256 y) public {
        int256 z;
        /// @solidity memory-safe-assembly
        assembly {
            z := add(x, y)
        }
        assertEq(FixedPointMathLib.rawAdd(x, y), z);
    }

    function testRawSub(uint256 x, uint256 y) public {
        uint256 z;
        /// @solidity memory-safe-assembly
        assembly {
            z := sub(x, y)
        }
        assertEq(FixedPointMathLib.rawSub(x, y), z);
    }

    function testRawSub(int256 x, int256 y) public {
        int256 z;
        /// @solidity memory-safe-assembly
        assembly {
            z := sub(x, y)
        }
        assertEq(FixedPointMathLib.rawSub(x, y), z);
    }

    function testRawMul(uint256 x, uint256 y) public {
        uint256 z;
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(x, y)
        }
        assertEq(FixedPointMathLib.rawMul(x, y), z);
    }

    function testRawMul(int256 x, int256 y) public {
        int256 z;
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(x, y)
        }
        assertEq(FixedPointMathLib.rawMul(x, y), z);
    }

    function testRawDiv(uint256 x, uint256 y) public {
        uint256 z;
        /// @solidity memory-safe-assembly
        assembly {
            z := div(x, y)
        }
        assertEq(FixedPointMathLib.rawDiv(x, y), z);
    }

    function testRawSDiv(int256 x, int256 y) public {
        int256 z;
        /// @solidity memory-safe-assembly
        assembly {
            z := sdiv(x, y)
        }
        assertEq(FixedPointMathLib.rawSDiv(x, y), z);
    }

    function testRawMod(uint256 x, uint256 y) public {
        uint256 z;
        /// @solidity memory-safe-assembly
        assembly {
            z := mod(x, y)
        }
        assertEq(FixedPointMathLib.rawMod(x, y), z);
    }

    function testRawSMod(int256 x, int256 y) public {
        int256 z;
        /// @solidity memory-safe-assembly
        assembly {
            z := smod(x, y)
        }
        assertEq(FixedPointMathLib.rawSMod(x, y), z);
    }

    function testRawAddMod(uint256 x, uint256 y, uint256 denominator) public {
        uint256 z;
        /// @solidity memory-safe-assembly
        assembly {
            z := addmod(x, y, denominator)
        }
        assertEq(FixedPointMathLib.rawAddMod(x, y, denominator), z);
    }

    function testRawMulMod(uint256 x, uint256 y, uint256 denominator) public {
        uint256 z;
        /// @solidity memory-safe-assembly
        assembly {
            z := mulmod(x, y, denominator)
        }
        assertEq(FixedPointMathLib.rawMulMod(x, y, denominator), z);
    }

    function testLog10() public {
        assertEq(FixedPointMathLib.log10(0), 0);
        assertEq(FixedPointMathLib.log10(1), 0);
        assertEq(FixedPointMathLib.log10(type(uint256).max), 77);
        unchecked {
            for (uint256 i = 1; i <= 77; ++i) {
                uint256 x = 10 ** i;
                assertEq(FixedPointMathLib.log10(x), i);
                assertEq(FixedPointMathLib.log10(x - 1), i - 1);
                assertEq(FixedPointMathLib.log10(x + 1), i);
            }
        }
    }

    function testLog10(uint256 i, uint256 j) public {
        i = _bound(i, 0, 77);
        uint256 low = 10 ** i;
        uint256 high = i == 77 ? type(uint256).max : (10 ** (i + 1)) - 1;
        uint256 x = _bound(j, low, high);
        assertEq(FixedPointMathLib.log10(x), i);
    }

    function testLog10Up() public {
        assertEq(FixedPointMathLib.log10Up(0), 0);
        assertEq(FixedPointMathLib.log10Up(1), 0);
        assertEq(FixedPointMathLib.log10Up(9), 1);
        assertEq(FixedPointMathLib.log10Up(10), 1);
        assertEq(FixedPointMathLib.log10Up(99), 2);
        assertEq(FixedPointMathLib.log10Up(100), 2);
        assertEq(FixedPointMathLib.log10Up(999), 3);
        assertEq(FixedPointMathLib.log10Up(1000), 3);
        assertEq(FixedPointMathLib.log10Up(10 ** 77), 77);
        assertEq(FixedPointMathLib.log10Up(10 ** 77 + 1), 78);
        assertEq(FixedPointMathLib.log10Up(type(uint256).max), 78);
    }

    function testLog256() public {
        assertEq(FixedPointMathLib.log256(0), 0);
        assertEq(FixedPointMathLib.log256(1), 0);
        assertEq(FixedPointMathLib.log256(256), 1);
        assertEq(FixedPointMathLib.log256(type(uint256).max), 31);
        unchecked {
            for (uint256 i = 1; i <= 31; ++i) {
                uint256 x = 256 ** i;
                assertEq(FixedPointMathLib.log256(x), i);
                assertEq(FixedPointMathLib.log256(x - 1), i - 1);
                assertEq(FixedPointMathLib.log256(x + 1), i);
            }
        }
    }

    function testLog256(uint256 i, uint256 j) public {
        i = _bound(i, 0, 31);
        uint256 low = 256 ** i;
        uint256 high = i == 31 ? type(uint256).max : (256 ** (i + 1)) - 1;
        uint256 x = _bound(j, low, high);
        assertEq(FixedPointMathLib.log256(x), i);
    }

    function testLog256Up() public {
        assertEq(FixedPointMathLib.log256Up(0), 0);
        assertEq(FixedPointMathLib.log256Up(0x01), 0);
        assertEq(FixedPointMathLib.log256Up(0x02), 1);
        assertEq(FixedPointMathLib.log256Up(0xff), 1);
        assertEq(FixedPointMathLib.log256Up(0x0100), 1);
        assertEq(FixedPointMathLib.log256Up(0x0101), 2);
        assertEq(FixedPointMathLib.log256Up(0xffff), 2);
        assertEq(FixedPointMathLib.log256Up(0x010000), 2);
        assertEq(FixedPointMathLib.log256Up(0x010001), 3);
        assertEq(FixedPointMathLib.log256Up(type(uint256).max - 1), 32);
        assertEq(FixedPointMathLib.log256Up(type(uint256).max), 32);
    }

    function testSci() public {
        _testSci(0, 0, 0);
        _testSci(1, 1, 0);
        _testSci(13, 13, 0);
        _testSci(130, 13, 1);
        _testSci(1300, 13, 2);
        unchecked {
            uint256 a = 103;
            uint256 exponent = 0;
            uint256 m = 1;
            uint256 n = 78 - FixedPointMathLib.log10Up(a);
            for (uint256 i; i < n; ++i) {
                _testSci(a * m, a, exponent);
                exponent += 1;
                m *= 10;
            }
        }
        _testSci(10 ** 77, 1, 77);
        _testSci(2 * (10 ** 76), 2, 76);
        _testSci(9 * (10 ** 76), 9, 76);
        unchecked {
            for (uint256 i; i < 32; ++i) {
                testSci(11 + i * i * 100);
            }
            for (uint256 i; i < 500; ++i) {
                _testSci(0, 0, 0);
            }
        }
        unchecked {
            uint256 x = 30_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_001;
            _testSci(x, x, 0);
        }
    }

    function testSci(uint256 a) public {
        unchecked {
            while (a % 10 == 0) a = _random();
            uint256 exponent = 0;
            uint256 m = 1;
            uint256 n = 78 - FixedPointMathLib.log10Up(a);
            for (uint256 i; i < n; ++i) {
                _testSci(a * m, a, exponent);
                uint256 x = a * 10 ** exponent;
                assertEq(x, a * m);
                exponent += 1;
                m *= 10;
            }
        }
    }

    function testSci2(uint256 x) public {
        unchecked {
            (uint256 mantissa, uint256 exponent) = FixedPointMathLib.sci(x);
            assertEq(x % 10 ** exponent, 0);
            if (x != 0) {
                assertTrue(x % 10 ** (exponent + 1) > 0);
                assertTrue(mantissa % 10 != 0);
            } else {
                assertEq(mantissa, 0);
                assertEq(exponent, 0);
            }
        }
    }

    function _testSci(uint256 x, uint256 expectedMantissa, uint256 expectedExponent) internal {
        (uint256 mantissa, uint256 exponent) = FixedPointMathLib.sci(x);
        assertEq(mantissa, expectedMantissa);
        assertEq(exponent, expectedExponent);
    }

    function testPackUnpackSci(uint256) public {
        unchecked {
            uint256 x = (_random() & 0x1) * 10 ** (_random() % 70);
            uint8 packed = uint8(FixedPointMathLib.packSci(x));
            uint256 unpacked = FixedPointMathLib.unpackSci(packed);
            assertEq(unpacked, x);
        }
        unchecked {
            uint256 x = (_random() & 0x1ff) * 10 ** (_random() % 70);
            uint16 packed = uint16(FixedPointMathLib.packSci(x));
            uint256 unpacked = FixedPointMathLib.unpackSci(packed);
            assertEq(unpacked, x);
        }
        unchecked {
            uint256 x = (_random() & 0x1ffffff) * 10 ** (_random() % 70);
            uint32 packed = uint32(FixedPointMathLib.packSci(x));
            uint256 unpacked = FixedPointMathLib.unpackSci(packed);
            assertEq(unpacked, x);
        }
        unchecked {
            uint256 x = (_random() & 0x1ffffffffffffff) * 10 ** (_random() % 60);
            uint64 packed = uint64(FixedPointMathLib.packSci(x));
            uint256 unpacked = FixedPointMathLib.unpackSci(packed);
            assertEq(unpacked, x);
        }
        unchecked {
            uint256 x = (_random() * 10 ** (_random() % 78)) & ((1 << 249) - 1);
            uint256 packed = FixedPointMathLib.packSci(x);
            uint256 unpacked = FixedPointMathLib.unpackSci(packed);
            assertEq(unpacked, x);
        }
    }

    function testPackUnpackSci() public {
        uint256 mantissaSize = 249;
        unchecked {
            for (uint256 i; i <= mantissaSize; ++i) {
                uint256 x = (1 << i) - 1;
                uint256 packed = FixedPointMathLib.packSci(x);
                uint256 unpacked = FixedPointMathLib.unpackSci(packed);
                assertEq(unpacked, x);
            }
        }
        unchecked {
            uint256 x = (1 << (mantissaSize + 1)) - 1;
            vm.expectRevert(FixedPointMathLib.MantissaOverflow.selector);
            FixedPointMathLib.packSci(x);
        }
    }
}
