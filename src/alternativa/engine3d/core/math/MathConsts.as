package alternativa.engine3d.core.math {
	/** В классе MathConsts определены наиболее часто используемые математические константы. */
	public class MathConsts {
		/** Перемножьте число записанное в радианах с этой константой для преобразования этого числа в градусы. */
		public static const RADIANS_TO_DEGREES : Number = 180 / Math.PI;

		/** Перемножьте число записанное в градусах с этой константой для преобразования этого числа в радианы. */
		public static const DEGREES_TO_RADIANS : Number = Math.PI / 180;
	}
}