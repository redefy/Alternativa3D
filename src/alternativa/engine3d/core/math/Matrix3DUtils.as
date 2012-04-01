package alternativa.engine3d.core.math {
	import flash.geom.*;
	
	/** Класс Matrix3DUtils содержит вспомогательные математические функции для работы с матрицами. */
	public class Matrix3DUtils {
		/** Вектор, который используется в качестве контейнера для хранения временных сырых данных. */
		public static const RAW_DATA_CONTAINER:Vector.<Number> = new Vector.<Number>(16);
		
		/**
		 * Возвращает нормализованный объект <code>Vector3D</code>, являющийся вектором направленным вперед от объекта.
		 * @param	m		матрица трансформации объекта.
		 * @param	v 		ссылка на объект Vector3D. Если вы укажите ссылку на объект Vector3D, то результат работы этой функции будет записан в этот объект,
		 * 					иначе же будет создан новый объект Vector3D, в который и будет записан результат работы этой функции. Значение по умолчанию: null.
		 * @return			вектор направленный вперед от объекта.
		 */
		public static function getForward(m:Matrix3D, v:Vector3D = null):Vector3D {
			v ||= new Vector3D(0.0, 0.0, 0.0);
			m.copyColumnTo(1, v);
			v.normalize();
			return v;
		}
		
		/**
		 * Возвращает нормализованный объект <code>Vector3D</code>, являющийся вектором направленным вверх от объекта.
		 * @param	m		матрица трансформации объекта.
		 * @param	v 		ссылка но объект Vector3D. Если вы укажите ссылку на объект Vector3D, то результат работы этой функции будет записан в этот объект,
		 * 					иначе же будет создан новый объект Vector3D, в который и будет записан результат работы этой функции. Значение по умолчанию: null.
		 * @return			вектор направленный вверх от объекта.
		 */
		public static function getUp(m:Matrix3D, v:Vector3D = null):Vector3D {
			v ||= new Vector3D(0.0, 0.0, 0.0);
			m.copyColumnTo(2, v);
			v.normalize();
			return v;
		}
		
		/**
		 * Возвращает нормализованный объект <code>Vector3D</code>, являющийся вектором направленным вправо от объекта.
		 * @param	m		матрица трансформации объекта.
		 * @param	v 		ссылка но объект Vector3D. Если вы укажите ссылку на объект Vector3D, то результат работы этой функции будет записан в этот объект,
		 * 					иначе же будет создан новый объект Vector3D, в который и будет записан результат работы этой функции. Значение по умолчанию: null.
		 * @return			вектор направленный вправо от объекта.
		 */
		public static function getRight(m:Matrix3D, v:Vector3D = null):Vector3D {
			v ||= new Vector3D(0.0, 0.0, 0.0);
			m.copyColumnTo(0, v);
			v.normalize();
			return v;
		}
		
		/**
		 * Сравнивает две матрицы.
		 * @param	m1 первая матрица участвующая в сравнении.
		 * @param	m2 вторая матрица участвующая в сравнении.
		 * @return  true, если две указанные матрицы являются одинаковыми, иначе false.
		 */
		public static function compare(m1:Matrix3D, m2:Matrix3D):Boolean {
			var r1:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
			var r2:Vector.<Number> = m2.rawData;
			m1.copyRawDataTo(r1);
			
			for (var i:uint = 0; i < 16; ++i)
				if (r1[i] != r2[i]) return false;
			
			return true;
		}
	}
}
