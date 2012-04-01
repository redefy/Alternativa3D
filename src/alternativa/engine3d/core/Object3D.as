/**
 * This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * If it is not possible or desirable to put the notice in a particular file, then You may include the notice in a location (such as a LICENSE file in a relevant directory) where a recipient would be likely to look for such a notice.
 * You may add additional accurate notices of copyright ownership.
 *
 * It is desirable to notify that Covered Software was "Powered by AlternativaPlatform" with link to http://www.alternativaplatform.com/ 
 */
package alternativa.engine3d.core {

	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.collisions.EllipsoidCollider;
	import alternativa.engine3d.core.events.Event3D;
	import alternativa.engine3d.core.math.MathConsts;
	import alternativa.engine3d.core.math.Matrix3DUtils;
	import alternativa.engine3d.materials.compiler.Linker;
	import alternativa.engine3d.materials.compiler.Procedure;
	import alternativa.engine3d.objects.Surface;

	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.events.IEventDispatcher;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	use namespace alternativa3d;

	/**
	 * Отправляется, когда объект добавляется в список детей. Это событие запускается следующими 
	 * методами: Object3D.addChild(), Object3D.addChildAt().
	 *
	 * @see #addChild()
	 * @see #addChildAt()
	 *
	 * @eventType alternativa.engine3d.core.events.Event3D.ADDED
	 */
	[Event(name="added",type="alternativa.engine3d.core.events.Event3D")]

	/**
	 * Отправляется перед удалением объекта из списка детей. Это событие генерируют два метода класса:
	 * Object3D.removeChild() и Object3D.removeChildAt().
	 *
	 * @see #removeChild()
	 * @see #removeChildAt()
	 * @eventType alternativa.engine3d.core.events.Event3D.REMOVED
	 */
	[Event(name="removed",type="alternativa.engine3d.core.events.Event3D")]

	/**
	 * Событие рассылается когда пользователь последовательно нажимает и отпускает левую
	 * кнопку мыши над одним и тем же объектом. Между нажатием и отпусканием кнопки могут
	 * происходить любые другие события.
	 *
	 * @eventType alternativa.engine3d.events.MouseEvent3D.CLICK
	 */
	[Event (name="click", type="alternativa.engine3d.core.events.MouseEvent3D")]

	/**
	 * Событие рассылается когда пользователь последовательно 2 раза нажимает и отпускает левую
	 * кнопку мыши над одним и тем же объектом. Событие сработает только если время между первым
	 * и вторым кликом вписывается в заданный в системе временной интервал.
	 *
	 * @eventType alternativa.engine3d.events.MouseEvent3D.DOUBLE_CLICK
	 */
	[Event (name="doubleClick", type="alternativa.engine3d.core.events.MouseEvent3D")]

	/**
	 * Событие рассылается когда пользователь нажимает левую кнопку мыши над объектом.
	 * @eventType alternativa.engine3d.events.MouseEvent3D.MOUSE_DOWN
	 */
	[Event (name="mouseDown", type="alternativa.engine3d.core.events.MouseEvent3D")]

	/**
	 * Событие рассылается когда пользователь отпускает левую кнопку мыши над объектом.
	 * @eventType alternativa.engine3d.events.MouseEvent3D.MOUSE_UP
	 */
	[Event (name="mouseUp", type="alternativa.engine3d.core.events.MouseEvent3D")]

	/**
	 * Событие рассылается когда пользователь наводит курсор мыши на объект.
	 * @eventType alternativa.engine3d.events.MouseEvent3D.MOUSE_OVER
	 */
	[Event (name="mouseOver", type="alternativa.engine3d.core.events.MouseEvent3D")]

	/**
	 * Событие рассылается когда пользователь уводит курсор мыши с объекта.
	 * @eventType alternativa.engine3d.events.MouseEvent3D.MOUSE_OUT
	 */
	[Event (name="mouseOut", type="alternativa.engine3d.core.events.MouseEvent3D")]

	/**
	 * Событие рассылается когда пользователь наводит курсор мыши на объект.
	 * @eventType alternativa.engine3d.events.MouseEvent3D.ROLL_OVER
	 */
	[Event (name="rollOver", type="alternativa.engine3d.core.events.MouseEvent3D")]

	/**
	 * Событие рассылается когда пользователь уводит курсор мыши с объекта.
	 * @eventType alternativa.engine3d.events.MouseEvent3D.ROLL_OUT
	 */
	[Event (name="rollOut", type="alternativa.engine3d.core.events.MouseEvent3D")]

	/**
	 * Событие рассылается когда пользователь перемещает курсор мыши над объектом.
	 * @eventType alternativa.engine3d.events.MouseEvent3D.MOUSE_MOVE
	 */
	[Event (name="mouseMove", type="alternativa.engine3d.core.events.MouseEvent3D")]

	/**
	 * Событие рассылается когда пользователь вращает колесо мыши над объектом.
	 * @eventType alternativa.engine3d.events.MouseEvent3D.MOUSE_WHEEL
	 */
	[Event (name="mouseWheel", type="alternativa.engine3d.core.events.MouseEvent3D")]

	/**
	 * Базовый класс для всех трехмерных объектов. У любого Object3D есть свойство трансформации,
	 * определяющее его положение в пространстве, свойство boundBox,описывающее участок пространства,
	 * в которое вписывается данный трехмерный объект в виде прямоугольного параллелипипеда. Последней 
	 * отличительной особенностью этого класса является однозначное место в иерархии трехмерного мира приложения.
	 * В отличие от предыдущей версии Alternativa3D, экземпляр этого класса может содержать множество детей,
	 * то есть в некотором смысле он может выступать в роли контейнера. Это же относится и ко всем наследникам Object3D.
	 *
	 * @see alternativa.engine3d.objects.Mesh
	 * @see alternativa.engine3d.core.BoundBox
	 */
	public class Object3D implements IEventDispatcher {

		/** Произвольные данные пользователя, связаные с объектом. */
		public var userData:Object;

		/** Флаг, определяющий могут на этот объект воздействовать источники света или нет. @private */ 
		public var useShadow:Boolean = true;

		/** 
		 * Матрица трансформации, для внутреннего использования, использующаяся в некоторых методах для 
		 * хранения временных значений.
		 * @private 
		 */
		alternativa3d static const trm:Transform3D = new Transform3D();

		/** Имя объекта. */
		public var name:String;

		/** Флаг видимости объекта. */
		public var visible:Boolean = true;

		/** Определяет, получает ли объект сообщения мыши. Значение по умолчанию — true. Логика идентична flash.display.InteractiveObject. */
		public var mouseEnabled:Boolean = true;
		
		/**
		 * Определяет, включен ли переход между потомками объекта с помощью мыши. Если
		 * false, то в качестве target события будет сам контейнер,
		 * независимо от его содержимого. Значение по умолчанию — true.
		 */
		public var mouseChildren:Boolean = true;
		
		/**
		 * Определяет, получает ли объект события doubleClick. Значение по умолчанию — false. 
		 * Примечание: для обработки события doubleClick необходимо установить в true свойство doubleClickEnabled 
		 * текущего Stage.
		 */
		public var doubleClickEnabled:Boolean = false;
		
		/** Логическое значение, определяющее, должен ли отображаться указатель "рука" при наведении указателя мыши. */
		public var useHandCursor:Boolean = false;
		
		/** Границы объекта. */
		public var boundBox:BoundBox;

		/** Позиция объекта по оси X относительно локальных координат родительского Object3D. @private */
		alternativa3d var _x:Number = 0;
		/** Позиция объекта по оси Y относительно локальных координат родительского Object3D. @private */
		alternativa3d var _y:Number = 0;
		/** Позиция объекта по оси Z относительно локальных координат родительского Object3D. @private */
		alternativa3d var _z:Number = 0;
		/** Вспомогательный вектор для хранения позиции объекта. @private */
		alternativa3d var _pos:Vector3D = new Vector3D();
		/** Угол поворота объекта вокруг оси X. Указывается в радианах. @private */
		alternativa3d var _rotationX:Number = 0;
		/** Угол поворота объекта вокруг оси Y. Указывается в радианах. @private */
		alternativa3d var _rotationY:Number = 0;
		/** Угол поворота объекта вокруг оси Z. Указывается в радианах. @private */
		alternativa3d var _rotationZ:Number = 0;
		/** Поворот 3D объекта. @private */
		alternativa3d var _eulers : Vector3D = new Vector3D();
		/** Коэффициент масштабирования объекта по оси X. @private */
		alternativa3d var _scaleX:Number = 1;
		/** Коэффициент масштабирования объекта по оси Y. @private */
		alternativa3d var _scaleY:Number = 1;
		/** Коэффициент масштабирования объекта по оси Z. @private */
		alternativa3d var _scaleZ:Number = 1;
		/** @private */
		alternativa3d var _m:Matrix3D = new Matrix3D();

		/** Ссылка на объект, который является родителем текущего объекта. @private */
		alternativa3d var _parent:Object3D;
		/** Список детей текущего объекта. @private */
		alternativa3d var childrenList:Object3D;
		/** Ссылка на следующий объект в списке. @private */
		alternativa3d var next:Object3D;
		/** Матрица трансформации объекта. @private */
		alternativa3d var transform:Transform3D = new Transform3D();
		/** Инвертированная матрица трансформации объекта. @private */
		alternativa3d var inverseTransform:Transform3D = new Transform3D();
		/** Флаг с помощью которого определяется, требуется обновить матрицу трансформации или нет. @private */
		alternativa3d var transformChanged:Boolean = true;
		/** Матрица для конвертирования координат камеры в локальные координаты объекта. @private */
		alternativa3d var cameraToLocalTransform:Transform3D = new Transform3D();
		/** Матрица для конвертирования локальных координат объекта в координаты камеры. @private */
		alternativa3d var localToCameraTransform:Transform3D = new Transform3D();
		/** Матрица для конвертирования локальных координат объекта в координаты коллайдера. @private */
		alternativa3d var localToGlobalTransform:Transform3D = new Transform3D();
		/** Матрица для конвертирования координат коллайдера в локальные координаты объекта. @private */
		alternativa3d var globalToLocalTransform:Transform3D = new Transform3D();
		/** Свойство содержит результат проверки пересечения баундбокса объекта с фрустумом камеры. @private */
		alternativa3d var culling:int;
		/** Свойство содержит результат проверки пересечения объекта с лучами-событиями мыши. @private */
		alternativa3d var listening:Boolean;
		/** Расстояние от текущего объекта до камеры. Используется объектом LOD для определения, какой объект рендерить. @private */
		alternativa3d var distance:Number;
		/** Объект, который будет хранить функции, вызываемые при наступлении определенного события в целевой или пузырьковой фазах. @private */
		alternativa3d var bubbleListeners:Object;
		/** Объект, который будет хранить функции, вызываемые при наступлении определенного события в фазе захвата. @private */
		alternativa3d var captureListeners:Object;
		/** @private */
		alternativa3d var transformProcedure:Procedure;
		/** @private */
		alternativa3d var deltaTransformProcedure:Procedure;

		/** Позиция объекта по оси X относительно локальных координат родительского Object3D. */
		public function get x():Number {return _x;}
		public function set x(value:Number):void {
			if (_x != value) {
				_x = value;
				//говорим, что матрицу трансформации объекта следует обновить
				transformChanged = true;
			}
		}

		/** Позиция объекта по оси Y относительно локальных координат родительского Object3D. */
		public function get y():Number {return _y;}
		public function set y(value:Number):void {
			if (_y != value) {
				_y = value;
				//говорим, что матрицу трансформации объекта следует обновить
				transformChanged = true;
			}
		}

		/** Позиция объекта по оси Z относительно локальных координат родительского Object3D. */
		public function get z():Number {return _z;}
		public function set z(value:Number):void {
			if (_z != value) {
				_z = value;
				//говорим, что матрицу трансформации объекта следует обновить
				transformChanged = true;
			}
		}
		
		/** Позиция 3D объекта. */
		public function get position() : Vector3D {
			matrix.copyColumnTo(3, _pos);
			return _pos.clone();
		}

		public function set position(value : Vector3D) : void {
			x = value.x;
			y = value.y;
			z = value.z;
		}

		/** Угол поворота объекта вокруг оси X. Указывается в радианах. */
		public function get rotationX():Number {return _rotationX * MathConsts.RADIANS_TO_DEGREES;}
		public function set rotationX(value:Number):void {
			if (rotationX != value) {
				_rotationX = value * MathConsts.DEGREES_TO_RADIANS;;
				transformChanged = true;
			}
		}

		/** Угол поворота объекта вокруг оси Y. Указывается в радианах. */
		public function get rotationY():Number {return _rotationY * MathConsts.RADIANS_TO_DEGREES;}
		public function set rotationY(value:Number):void {
			if (rotationY != value) {
				_rotationY = value * MathConsts.DEGREES_TO_RADIANS;
				transformChanged = true;
			}
		}

		/** Угол поворота объекта вокруг оси Z. Указывается в радианах. */
		public function get rotationZ():Number {return _rotationZ * MathConsts.RADIANS_TO_DEGREES;}
		public function set rotationZ(value:Number):void {
			if (rotationZ != value) {
				_rotationZ = value * MathConsts.DEGREES_TO_RADIANS;
				transformChanged = true;
			}
		}
		
		/** Поворот 3D объекта. Для этого используется объект <code>Vector3D</code> содержащий углы поворота по осям x, y и z. */
		public function get eulers() : Vector3D {
			_eulers.x = rotationX;
			_eulers.y = rotationY;
			_eulers.z = rotationZ;
			
			return _eulers;
		}
		public function set eulers(value : Vector3D) : void {
			rotationX = value.x;
			rotationY = value.y;
			rotationZ = value.z;
		}

		/** Коэффициент масштабирования объекта по оси X. */
		public function get scaleX():Number { return _scaleX; }
		public function set scaleX(value:Number):void {
			if (_scaleX != value) {
				_scaleX = value;
				transformChanged = true;
			}
		}

		/** Коэффициент масштабирования объекта по оси Y. */
		public function get scaleY():Number {return _scaleY;}
		public function set scaleY(value:Number):void {
			if (_scaleY != value) {
				_scaleY = value;
				transformChanged = true;
			}
		}

		/** Коэффициент масштабирования объекта по оси Z. */
		public function get scaleZ():Number {return _scaleZ;}
		public function set scaleZ(value:Number):void {
			if (_scaleZ != value) {
				_scaleZ = value;
				transformChanged = true;
			}
		}
		
		/**
		 * Равномерно масштабирует объект по всем трем осям.
		 * @param value величина масштабирования.
		 */
		public function scale(value : Number) : void {
			scaleX *= value;
			scaleY *= value;
			scaleZ *= value;
		}
		
		/** Нормаль направленная вперёд от объекта.  */
		public function get forwardVector():Vector3D {return Matrix3DUtils.getForward(matrix);}
		/**  Нормаль направленная вправо от объекта. */
		public function get rightVector():Vector3D {return Matrix3DUtils.getRight(matrix);}
		/** Нормаль направленная вверх от объекта.  */
		public function get upVector():Vector3D { return Matrix3DUtils.getUp(matrix); }
		
		/** Нормаль направленная назад от объекта.  */
		public function get backVector():Vector3D {
			var director:Vector3D = Matrix3DUtils.getForward(matrix);
			director.negate();
			return director;
		}
		
		/** Нормаль направленная влево от объекта.  */
		public function get leftVector():Vector3D {
			var director:Vector3D = Matrix3DUtils.getRight(matrix);
			director.negate();
			return director;
		}
		
		/** Нормаль направленная вниз от объекта.  */
		public function get downVector():Vector3D {
			var director:Vector3D = Matrix3DUtils.getUp(matrix);
			director.negate();
			return director;
		}
		
		/**
		 * Перемещает 3D объект вперед вдоль его локальной оси z.
		 * @param	distance	длина перемещения.
		 */
		public function moveForward(distance : Number) : void {
			translateLocal(Vector3D.Y_AXIS, distance);
		}

		/**
		 * Перемещает 3D объект назад вдоль его локальной оси z.
		 * @param	distance	длина перемещения.
		 */
		public function moveBackward(distance : Number) : void {
			translateLocal(Vector3D.Y_AXIS, -distance);
		}

		/**
		 * Перемещает 3D объект назад вдоль его локальной оси x.
		 * @param	distance	длина перемещения.
		 */
		public function moveLeft(distance : Number) : void {
			translateLocal(Vector3D.X_AXIS, -distance);
		}

		/**
		 * Перемещает 3D объект вперед вдоль его локальной оси x.
		 * @param	distance	длина перемещения.
		 */
		public function moveRight(distance : Number) : void {
			translateLocal(Vector3D.X_AXIS, distance);
		}

		/**
		 * Перемещает 3D объект вперед вдоль его локальной оси y.
		 * @param	distance	длина перемещения.
		 */
		public function moveUp(distance : Number) : void {
			translateLocal(Vector3D.Z_AXIS, distance);
		}

		/**
		 * Перемещает 3D объект назад вдоль его локальной оси y.
		 * @param	distance	длина перемещения.
		 */
		public function moveDown(distance : Number) : void {
			translateLocal(Vector3D.Z_AXIS, -distance);
		}

		/**
		 * Перемещает 3D объект в указанную точку.
		 * @param	dx		координата по оси x.
		 * @param	dy		координата по оси y.
		 * @param	dz		координата по оси z.
		 */
		public function moveTo(dx : Number, dy : Number, dz : Number) : void {
			x = dx;
			y = dy;
			z = dz;
		}
		
		/**
		 * Перемещает 3D-объект вдоль вектора на определенную длину.
		 * @param	axis		вектор, определяющий направление движения.
		 * @param	distance	длина перемещения.
		 */
		public function translate(axis : Vector3D, distance : Number) : void {
			var x : Number = axis.x, y : Number = axis.y, z : Number = axis.z;
			var len : Number = distance / Math.sqrt(x* x + y * y + z * z);

			this.x += x * len;
			this.y += y * len;
			this.z += z * len;
		}

		/**
		 * Перемещает 3D-объект вдоль вектора на определенную длину.
		 * @param	axis		вектор, определяющий направление движения.
		 * @param	distance	длина перемещения.
		 */
		public function translateLocal(axis : Vector3D, distance : Number) : void {
			var x : Number = axis.x, y : Number = axis.y, z : Number = axis.z;
			var len : Number = distance / Math.sqrt(x * x + y * y + z * z);
		
			_m = matrix;
			_m.prependTranslation(x * len, y * len, z * len)
			_m.copyColumnTo(3, _pos);
			
			this.x = _pos.x;
			this.y = _pos.y;
			this.z = _pos.z;
		}
		
		/**
		 * Поворачивает 3D-объект вокруг локальной оси x.
		 * @param	angle		величина поворота в градусах.
		 */
		public function pitch(angle : Number) : void {rotate(Vector3D.X_AXIS, angle);}

		/**
		 * Поворачивает 3D-объект вокруг локальной оси y.
		 * @param	angle		величина поворота в градусах.
		 */
		public function yaw(angle : Number) : void {rotate(Vector3D.Z_AXIS, angle);}

		/**
		 * Поворачивает 3D-объект вокруг локальной оси z.
		 * @param	angle		величина поворота в градусах.
		 */
		public function roll(angle : Number) : void { rotate(Vector3D.Y_AXIS, angle); }
		
		/**
		 * Поворачивает 3D-объект.
		 * @param	ax		угол поворота в градусах вокруг оси x.
		 * @param	ay		угол поворота в градусах вокруг оси y.
		 * @param	az		угол поворота в градусах вокруг оси z.
		 */
		public function rotateTo(ax : Number, ay : Number, az : Number) : void {
			rotationX = ax;
			rotationY = ay;
			rotationZ = az;
		}

		/**
		 * Поворачивает 3D-объект вокруг указанной оси на указанный угол.
		 * @param	axis		вектор, определяющий ось вращения
		 * @param	angle		угол поворота в градусах.
		 */
		public function rotate(axis : Vector3D, angle : Number) : void {
			_m = matrix;
			_m.prependRotation(angle, axis);
			matrix = _m;
		}

		/** Объект Matrix3D, содержащий значения, влияющие на масштабирование, поворот и перемещение объекта. */
		public function get matrix():Matrix3D {
			//перед возвратом объекта Matrix3D из геттера, если это требуется, обновим матрицу трансформации transform класса Transform3D
			if (transformChanged) composeTransforms();
			return new Matrix3D(Vector.<Number>([transform.a, transform.e, transform.i, 0, transform.b, transform.f, transform.j, 0, transform.c, transform.g, transform.k, 0, transform.d, transform.h, transform.l, 1]));
		}
		public function set matrix(value:Matrix3D):void {
			//разбиваем матрицу на три ветора
			var v:Vector.<Vector3D> = value.decompose();
			//позиция
			var t:Vector3D = v[0];
			//поворот
			var r:Vector3D = v[1];
			//масштаб
			var s:Vector3D = v[2];
			//обновляем внутренние переменные
			_x = t.x;
			_y = t.y;
			_z = t.z;
			_rotationX = r.x;
			_rotationY = r.y;
			_rotationZ = r.z;
			_scaleX = s.x;
			_scaleY = s.y;
			_scaleZ = s.z;
			//и предписываем обновиться матрице трансформации
			transformChanged = true;
		}

		/**
		 * Осуществляет поиск пересечения луча с объектом.
		 * @param origin 	начало луча.
		 * @param direction направление луча.
		 * @return 			результат поиска пересечения — объект RayIntersectionData. Если пересечения нет, будет возвращён null.
		 * 
		 * @see RayIntersectionData
		 * @see alternativa.engine3d.objects.Sprite3D
		 * @see alternativa.engine3d.core.Camera3D#calculateRay()
		 */
		public function intersectRay(origin:Vector3D, direction:Vector3D):RayIntersectionData {
			return intersectRayChildren(origin, direction);
		}

		/**
		 * Ищет пересечение луча с детьми текущего объекта.
		 * @param	origin		начало луча.
		 * @param	direction	направление луча.
		 * @return				результат поиска пересечения — объект RayIntersectionData.
		 * @private
		 */
		alternativa3d function intersectRayChildren(origin:Vector3D, direction:Vector3D):RayIntersectionData {
			var minTime:Number = 1e22;
			var minData:RayIntersectionData = null;
			var childOrigin:Vector3D;
			var childDirection:Vector3D;
			//пробегаемся по всем детям текущего объекта 
			for (var child:Object3D = childrenList; child != null; child = child.next) {
				//если необходимо обновляем матрицу трансформации
				if (child.transformChanged) child.composeTransforms();
				//инициализируем вспомогательные векторы, если они не были инициализированы ранее
				if (childOrigin == null) {
					childOrigin = new Vector3D();
					childDirection = new Vector3D();
				}
				//переводим начало и направление луча в пространство дочернего объекта child
				childOrigin.x = child.inverseTransform.a*origin.x + child.inverseTransform.b*origin.y + child.inverseTransform.c*origin.z + child.inverseTransform.d;
				childOrigin.y = child.inverseTransform.e*origin.x + child.inverseTransform.f*origin.y + child.inverseTransform.g*origin.z + child.inverseTransform.h;
				childOrigin.z = child.inverseTransform.i*origin.x + child.inverseTransform.j*origin.y + child.inverseTransform.k*origin.z + child.inverseTransform.l;
				childDirection.x = child.inverseTransform.a*direction.x + child.inverseTransform.b*direction.y + child.inverseTransform.c*direction.z;
				childDirection.y = child.inverseTransform.e*direction.x + child.inverseTransform.f*direction.y + child.inverseTransform.g*direction.z;
				childDirection.z = child.inverseTransform.i * direction.x + child.inverseTransform.j * direction.y + child.inverseTransform.k * direction.z;
				//проверяем пересечение объекта, в объектах Mesh и LOD пересечение проверяется с геометрией.
				//В этих классах метод intersectRay переопределен для реализации этой функциональности
				var data:RayIntersectionData = child.intersectRay(childOrigin, childDirection);
				if (data != null && data.time < minTime) {
					minData = data;
					minTime = data.time;
				}
			}
			return minData;
		}

		/** Объект Matrix3D, представляющий объединенные матрицы преобразования объекта и всех его родительских объектов, вплоть до корневого уровня. */
		public function get concatenatedMatrix():Matrix3D {
			if (transformChanged) composeTransforms();
			trm.copy(transform);
			var root:Object3D = this;
			//пробегаемся по всем родителям текущего объекта и перемножаем
			//все матрицы трансформации.
			while (root.parent != null) {
				root = root.parent;
				if (root.transformChanged) root.composeTransforms();
				trm.append(root.transform);
			}
			return new Matrix3D(Vector.<Number>([trm.a, trm.e, trm.i, 0, trm.b, trm.f, trm.j, 0, trm.c, trm.g, trm.k, 0, trm.d, trm.h, trm.l, 1]));
		}

		/**
		 * Преобразует точку из локальных координат в глобальные.
		 * @param point точка в локальных координатах объекта.
		 * @return 		точка в глобальном пространстве.
		 */
		public function localToGlobal(point:Vector3D):Vector3D {
			if (transformChanged) composeTransforms();
			// перемножаем все матрицы трансформации вплоть до корневого уровня
			trm.copy(transform);
			var root:Object3D = this;
			while (root.parent != null) {
				root = root.parent;
				if (root.transformChanged) root.composeTransforms();
				trm.append(root.transform);
			}
			//переводим точку в пространство полученной матрицы транформации 
			var res:Vector3D = new Vector3D();
			res.x = trm.a*point.x + trm.b*point.y + trm.c*point.z + trm.d;
			res.y = trm.e*point.x + trm.f*point.y + trm.g*point.z + trm.h;
			res.z = trm.i*point.x + trm.j*point.y + trm.k*point.z + trm.l;
			return res;
		}

		/**
		 * Преобразует точку из глобальной системы координат в локальные координаты объекта.
		 * @param point точка в глобальном пространстве.
		 * @return 		точка в локальных координатах объекта.
		 */
		public function globalToLocal(point:Vector3D):Vector3D {
			if (transformChanged) composeTransforms();
			// перемножаем все инвертированные матрицы трансформации вплоть до корневого уровня
			trm.copy(inverseTransform);
			var root:Object3D = this;
			while (root.parent != null) {
				root = root.parent;
				if (root.transformChanged) root.composeTransforms();
				trm.prepend(root.inverseTransform);
			}
			//переводим точку в пространство полученной матрицы транформации 
			var res:Vector3D = new Vector3D();
			res.x = trm.a*point.x + trm.b*point.y + trm.c*point.z + trm.d;
			res.y = trm.e*point.x + trm.f*point.y + trm.g*point.z + trm.h;
			res.z = trm.i*point.x + trm.j*point.y + trm.k*point.z + trm.l;
			return res;
		}

		/** 
		 * Определяет, могут ли на этот объект оказывать воздействие источники света:
		 * DirectionalLight, OmniLight, SpotLight.
		 * @private 
		 */
		alternativa3d function get useLights():Boolean {return false;}

		/** Расчитывает баундбокс объекта в его системе координат. */
		public function calculateBoundBox():void {
			//сбрасываем текущие параметры баундбокса
			if (boundBox != null) {
				boundBox.reset();
			} else {
				boundBox = new BoundBox();
			}
			//и пересчитываем их
			updateBoundBox(boundBox, null);
		}

		/**
		 * Расчитывает параметры баундбокса текущего объекта.
		 * @param	boundBox	баундбокс, параметры которого должны быть обновлены. 
		 * @param	transform	матрица трансформации, на основе которой будет определяться позиция баундбокса на сцене.
		 * @private
		 */
		alternativa3d function updateBoundBox(boundBox:BoundBox, transform:Transform3D = null):void {}

		/**
		 * Регистрирует объект прослушивателя события на объекте EventDispatcher для получения прослушивателем уведомления о событии.
		 * @param type 				тип события.
		 * @param listener 			функция прослушивателя, обрабатывающая событие.
		 * @param useCapture  		определяет, работает ли прослушиватель в фазе захвата или в целевой фазе и в фазе восходящей цепочки.
		 * @param priority 			уровень приоритета прослушивателя событий. 
		 * @param useWeakReference  определяет, является ли ссылка на прослушиватель «сильной» или «слабой». Не используется.
		 */
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			if (listener == null) throw new TypeError("Parameter listener must be non-null.");
			var listeners:Object;
			//если слушатель должен обрабатывать событие только в фазе захвата,
			if (useCapture) {
				//то получаем ссылку на объект captureListeners, который как раз хранит такие слушатели
				if (captureListeners == null) captureListeners = new Object();
				listeners = captureListeners;
			} else {
				//если же слушатель должен обрабатывать событие в целевой и пузырьковой фазах,
				//то получаем ссылку на объект bubbleListeners, который как раз хранит такие слушатели
				if (bubbleListeners == null) bubbleListeners = new Object();
				listeners = bubbleListeners;
			}
			//получаем ссылку на вектор, который хранит все функции для определенного типа события
			var vector:Vector.<Function> = listeners[type];
			//если такой вектор еще не был инициализирован ранее, то инициализируем его
			if (vector == null) {
				vector = new Vector.<Function>();
				listeners[type] = vector;
			}
			//если указанная функция (listener) еще не была зарегестрирована в векторе,
			//то добавляем ее в вектор
			if (vector.indexOf(listener) < 0) {
				vector.push(listener);
			}
		}

		/**
		 * Удаляет прослушиватель из объекта EventDispatcher. 
		 * @param type 			тип события.
		 * @param listener 		удаляемый объект прослушивателя.
		 * @param useCapture 	указывает, был ли слушатель зарегистрирован для фазы захвата или целевой фазы и фазы восходящей цепочки.
		 */
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			if (listener == null) throw new TypeError("Parameter listener must be non-null.");
			//определяемся где искать слушатель, в каком объекте
			var listeners:Object = useCapture ? captureListeners : bubbleListeners;
			if (listeners != null) {
				//вектор с функциями-слушателями указанных типов событий
				var vector:Vector.<Function> = listeners[type];
				if (vector != null) {
					//находим в векторе функцию, которая должна отписаться от слушателя
					var i:int = vector.indexOf(listener);
					if (i >= 0) {
						//сдвигаем функции в векторе на одну позицию ниже
						var length:int = vector.length;
						for (var j:int = i + 1; j < length; j++,i++) {
							vector[i] = vector[j];
						}
						//укорачиваем длину вектора на 1, если длина вектора больше 1 
						if (length > 1) {
							vector.length = length - 1;
						} else {
							//если вектор пустой, то есть все функции были удалены,
							//то удаляем вектор за ненадобностью
							delete listeners[type];
							var key:*;
							//проверяем остался ли хоть один слушатель в объекте 
							//captureListeners или bubbleListeners
							for (key in listeners) break;
							//если нет, уничтожаем и объект хранящий функции, вызываемые
							//при наступлении определенного события
							if (!key) {
								if (listeners == captureListeners) {
									captureListeners = null;
								} else {
									bubbleListeners = null;
								}
							}
						}
					}
				}
			}
		}

		/**
		 * Проверяет наличие зарегистрированных обработчиков события указанного типа в объекте.
		 * @param type 	тип события.
		 * @return 		true если есть обработчики события указанного типа, иначе false.
		 */
		public function hasEventListener(type:String):Boolean {
			return captureListeners != null && captureListeners[type] || bubbleListeners != null && bubbleListeners[type];
		}

		/**
		 * Проверяет наличие зарегистрированных обработчиков события указанного типа в объекте или в любом из его предков.
		 * @param type  тип события.
		 * @return 		true если есть обработчики события указанного типа, иначе false.
		 */
		public function willTrigger(type:String):Boolean {
			//пробегаемся по всем родителям текущего объекта, и смотрим, нету ли
			//в объектах captureListeners или bubbleListeners событий указанного типа.
			//Если есть возвращаем true, иначе false.
			for (var object:Object3D = this; object != null; object = object._parent) {
				if (object.captureListeners != null && object.captureListeners[type] || object.bubbleListeners != null && object.bubbleListeners[type]) return true;
			}
			return false;
		}

		/**
		 * Передает событие в поток событий. При использовании событий - наследников класса Event не будут 
		 * установлены свойства target и currentTarget, данные свойства устанавливаются только с событиями 
		 * - экземплярами наследников класса Event3D.
		 * @param event объект Event, отправляемый в поток событий.
		 * @return 		true если событие было успешно отправлено, иначе false.
		 */
		public function dispatchEvent(event:Event):Boolean {
			if (event == null) throw new TypeError("Parameter event must be non-null.");
			var event3D:Event3D = event as Event3D;
			if (event3D != null) {
				event3D._target = this;
			}
			var branch:Vector.<Object3D> = new Vector.<Object3D>();
			var branchLength:int = 0;
			var object:Object3D;
			var i:int;
			var j:int;
			var length:int;
			var vector:Vector.<Function>;
			var functions:Vector.<Function>;
			//заносим ссылки на всех родителей текущего объекта в вектор branch
			for (object = this; object != null; object = object._parent) {
				branch[branchLength] = object;
				branchLength++;
			}
			// если у этих объектов есть зарегистрированные функции в объекте captureListeners (фаза захвата),
			// то вызываем эти функции, передавая в них объект Event3D
			for (i = branchLength - 1; i > 0; i--) {
				object = branch[i];
				if (event3D != null) {
					event3D._currentTarget = object;
					event3D._eventPhase = EventPhase.CAPTURING_PHASE;
				}

				if (object.captureListeners != null) {
					vector = object.captureListeners[event.type];
					if (vector != null) {
						length = vector.length;
						functions = new Vector.<Function>();
						for (j = 0; j < length; j++) functions[j] = vector[j];
						for (j = 0; j < length; j++) (functions[j] as Function).call(null, event);
					}
				}
			}
			if (event3D != null) {
				event3D._eventPhase = EventPhase.AT_TARGET;
			}
			// если у этих объектов есть зарегистрированные функции в объекте bubbleListeners (целевая и пузырьковая фазы),
			// то вызываем эти функции, передавая в них объект Event3D
			for (i = 0; i < branchLength; i++) {
				object = branch[i];
				if (event3D != null) {
					event3D._currentTarget = object;
					if (i > 0) {
						event3D._eventPhase = EventPhase.BUBBLING_PHASE;
					}
				}
				if (object.bubbleListeners != null) {
					vector = object.bubbleListeners[event.type];
					if (vector != null) {
						length = vector.length;
						functions = new Vector.<Function>();
						for (j = 0; j < length; j++) functions[j] = vector[j];
						for (j = 0; j < length; j++) (functions[j] as Function).call(null, event);
					}
				}
				if (!event.bubbles) break;
			}
			return true;
		}

		/** Ссылка на родительский объект Object3D. */
		public function get parent():Object3D {return _parent;}

		/** Удаляет текущий объект из родителя. @private */
		alternativa3d function removeFromParent():void {
			if (_parent != null) {
				_parent.removeFromList(this);
				_parent = null;
			}
		}

		/**
		 * Добавляет дочерний объект. Объект добавляется в конец списка. Если добавляется объект,
		 * предком которого уже является другой контейнер, то объект удаляется из списка потомков 
		 * старого контейнера.
		 * @param	child 	добавляемый дочерний объект.
		 * @return 			экземпляр Object3D, передаваемый в параметре child.
		 */
		public function addChild(child:Object3D):Object3D {
			// проверяем, был ли передан действительно объект Object3D или null
			if (child == null) throw new TypeError("Parameter child must be non-null.");
			//проверяем не является ли переданный объект текущим 
			if (child == this) throw new ArgumentError("An object cannot be added as a child of itself.");
			//убеждаемся, что добавляемый объект не является родителем текущего
			for (var container:Object3D = _parent; container != null; container = container._parent) {
				if (container == child) throw new ArgumentError("An object cannot be added as a child to one of it's children (or children's children, etc.).");
			}
			
			//если добавляемый объект не содержится в этом контейнере
			if (child._parent != this) {
				//удаляем добавляемый объект из его родителя
				if (child._parent != null) child._parent.removeChild(child);
				//добавляем объект в конец списка
				addToList(child);
				//родителем теперь для добавляемого объекта является текущий контейнер
				child._parent = this;
				//если висит тригер на этом объекте, диспатчим ему событие добавления в контейнер
				if (child.willTrigger(Event3D.ADDED)) child.dispatchEvent(new Event3D(Event3D.ADDED, true));
			} else {
				//если добавляемый объект уже находится в этом контейнере
				//удаляем его из списка
				child = removeFromList(child);
				if (child == null) throw new ArgumentError("Cannot add child.");
				//и добавляем заново
				addToList(child);
			}
			return child;
		}

		/**
		 * Удаляет дочерний объект. Свойство parent удаленного объекта получает значение null.
		 * @param child удаляемый дочерний объект.
		 * @return 		экземпляр Object3D, передаваемый в параметре child.
		 */
		public function removeChild(child:Object3D):Object3D {
			// проверка переданных в метод данных
			if (child == null) throw new TypeError("Parameter child must be non-null.");
			if (child._parent != this) throw new ArgumentError("The supplied Object3D must be a child of the caller.");
			child = removeFromList(child);
			if (child == null) throw new ArgumentError("Cannot remove child.");
			//если висит тригер на этом объекте, диспатчим ему событие удаления из контейнера
			if (child.willTrigger(Event3D.REMOVED)) child.dispatchEvent(new Event3D(Event3D.REMOVED, true));
			child._parent = null;
			return child;
		}

		/**
		 * Добавляет дочерний объект. Объект добавляется в указанную позицию в списке.
		 * @param	child добавляемый дочерний объект.
		 * @param	index позиция, в которую добавляется дочерний объект. Если указать занятую на данный момент позицию индекса, 
		 * 				  дочерний объект, существующий на этой и на этой позиции, и все выше расположенные позиции перемещаются 
		 *  			  на одну позицию вверх в списке потомков.
		 * @return		  экземпляр Object3D, передаваемый в параметре child.
		 */
		public function addChildAt(child:Object3D, index:int):Object3D {
			// проверка переданных в метод данных
			if (child == null) throw new TypeError("Parameter child must be non-null.");
			if (child == this) throw new ArgumentError("An object cannot be added as a child of itself.");
			if (index < 0) throw new RangeError("The supplied index is out of bounds.");
			for (var container:Object3D = _parent; container != null; container = container._parent) {
				if (container == child) throw new ArgumentError("An object cannot be added as a child to one of it's children (or children's children, etc.).");
			}
			
			//получаем ссылку на первый объект списка
			var current:Object3D = childrenList;
			//находим объект в списке на который должен ссылаться добавляемый объект
			for (var i:int = 0; i < index; i++) {
				if (current == null) throw new RangeError("The supplied index is out of bounds.");
				current = current.next;
			}
			
			//если добавляемый объект не содержится в этом контейнере
			if (child._parent != this) {
				//удаляем добавляемый объект из его родителя
				if (child._parent != null) child._parent.removeChild(child);
				//добавляем объект в список перед current
				addToList(child, current);
				//родителем теперь для добавляемого объекта является текущий контейнер
				child._parent = this;
				//если висит тригер на этом объекте, диспатчим ему событие добавления в контейнер
				if (child.willTrigger(Event3D.ADDED)) child.dispatchEvent(new Event3D(Event3D.ADDED, true));
			} else {
				//если добавляемый объект уже находится в этом контейнере
				//удаляем его из списка
				child = removeFromList(child);
				if (child == null) throw new ArgumentError("Cannot add child.");
				//и добавляем заново
				addToList(child, current);
			}
			return child;
		}

		/**
		 * Удаляет дочерний объект из указанной позиции. Свойство parent удаленного объекта получает значение null.
		 * @param index позиция, из которой удаляется дочерний объект.
		 * @return 		удаленный экземпляр Object3D.
		 */
		public function removeChildAt(index:int):Object3D {
			// проверка переданных в метод данных
			if (index < 0) throw new RangeError("The supplied index is out of bounds.");
			//получаем ссылку на первый объект списка
			var child:Object3D = childrenList;
			//находим объект в списке который находится в указанной позиции
			for (var i:int = 0; i < index; i++) {
				if (child == null) throw new RangeError("The supplied index is out of bounds.");
				child = child.next;
			}
			if (child == null) throw new RangeError("The supplied index is out of bounds.");
			// удаляем объект из списка
			removeFromList(child);
			//если висит тригер на этом объекте, диспатчим ему событие удаления из контейнера
			if (child.willTrigger(Event3D.REMOVED)) child.dispatchEvent(new Event3D(Event3D.REMOVED, true));
			child._parent = null;
			return child;
		}
		
		/**
		 * Удаляет дочерние объекты в указанном диапазоне.
		 * @param beginIndex 	начальная позиция.
		 * @param endIndex 		конечная позиция.
		 */
		public function removeChildren(beginIndex:int = 0, endIndex:int = 2147483647):void {
			// проверка переданных в метод данных
			if (beginIndex < 0) throw new RangeError("The supplied index is out of bounds.");
			if (endIndex < beginIndex) throw new RangeError("The supplied index is out of bounds.");
			var i:int = 0;
			
			//объект, находящийся в списке детей перед объектом begin
			var prev:Object3D = null;
			//находим объект, который находится в списке в позиции beginIndex
			var begin:Object3D = childrenList;
			while (i < beginIndex) {
				if (begin == null) {
					if (endIndex < 2147483647)
						throw new RangeError("The supplied index is out of bounds.");
					else
						return;
				}
				prev = begin;
				begin = begin.next;
				i++;
			}
			if (begin == null) {
				if (endIndex < 2147483647)
					throw new RangeError("The supplied index is out of bounds.");
				else 
					return;
			}
			
			//находим объект, который находится в списке детей в позиции endIndex
			var end:Object3D = null;
			if (endIndex < 2147483647) {
				end = begin;
				while (i <= endIndex) {
					if (end == null) throw new RangeError("The supplied index is out of bounds.");
					end = end.next;
					i++;
				}
			}
			//если beginIndex был равен 0,
			//то теперь первым объектом в списке детей текущего объекта будет
			//объект end, то есть объект находящийся в списке после последнего удаляемого объекта.
			//Иначе заставляем объект prev(объект находящийся перед первым удаленным) 
			//ссылаться на объект end(первый после последнего удаленного) 
			if (prev != null)
				prev.next = end;
			else
				childrenList = end;
			
			// удаляем детей из списка
			while (begin != end) {
				var next:Object3D = begin.next;
				begin.next = null;
				//если висит тригер на этом объекте, диспатчим ему событие удаления из контейнера
				if (begin.willTrigger(Event3D.REMOVED)) begin.dispatchEvent(new Event3D(Event3D.REMOVED, true));
				begin._parent = null;
				begin = next;
			}
		}
		
		/**
		 * Возвращает экземпляр дочернего объекта, находящийся в указанной позиции.
		 * @param index позиция дочернего объекта.
		 * @return 		дочерний объект находящийся в указанной позиции.
		 */
		public function getChildAt(index:int):Object3D {
			// проверка переданных в метод данных
			if (index < 0) throw new RangeError("The supplied index is out of bounds.");
			//пробегаемся по списку пока не дойдем до объекта, который находится в
			//указанном индексе
			var current:Object3D = childrenList;
			for (var i:int = 0; i < index; i++) {
				if (current == null) throw new RangeError("The supplied index is out of bounds.");
				current = current.next;
			}
			if (current == null) throw new RangeError("The supplied index is out of bounds.");
			return current;
		}

		/**
		 * Возвращает позицию дочернего объекта.
		 * @param child дочерний объект.
		 * @return 		позиция заданного дочернего объекта.
		 */
		public function getChildIndex(child:Object3D):int {
			// проверка переданных в метод данных
			if (child == null) throw new TypeError("Parameter child must be non-null.");
			if (child._parent != this) throw new ArgumentError("The supplied Object3D must be a child of the caller.");
			//опять же, пробегаемся по списку, и если находим объект,
			//который является объектом child, возвращаем его индекс
			var index:int = 0;
			for (var current:Object3D = childrenList; current != null; current = current.next) {
				if (current == child) return index;
				index++;
			}
			throw new ArgumentError("Cannot get child index.");
		}

		/**
		 * Устанавливает позицию дочернего объекта.
		 * @param child дочерний объект.
		 * @param index устанавливаемая позиция объекта.
		 */
		public function setChildIndex(child:Object3D, index:int):void {
			// проверка переданных в метод данных
			if (child == null) throw new TypeError("Parameter child must be non-null.");
			if (child._parent != this) throw new ArgumentError("The supplied Object3D must be a child of the caller.");
			if (index < 0) throw new RangeError("The supplied index is out of bounds.");
			// находим в списке объект, на который должен ссылаться объект child
			var current:Object3D = childrenList;
			for (var i:int = 0; i < index; i++) {
				if (current == null) throw new RangeError("The supplied index is out of bounds.");
				current = current.next;
			}
			// удаляем объект child из списка детей
			child = removeFromList(child);
			if (child == null) throw new ArgumentError("Cannot set child index.");
			// и добавляем снова, но уже перед объектом current
			addToList(child, current);
		}

		/**
		 * Меняет местами два дочерних объекта в списке.
		 * @param child1 первый дочерний объект.
		 * @param child2 второй дочерний объект.
		 */
		public function swapChildren(child1:Object3D, child2:Object3D):void {
			// проверка переданных в метод данных
			if (child1 == null || child2 == null) throw new TypeError("Parameter child must be non-null.");
			if (child1._parent != this || child2._parent != this) throw new ArgumentError("The supplied Object3D must be a child of the caller.");
			// если объект child1 указывает на объект child2, или наоборот,
			// то сразу же удаляем один объект из списка и добавляем в позицию другого
			if (child1 != child2) {
				if (child1.next == child2) {
					child2 = removeFromList(child2);
					if (child2 == null) throw new ArgumentError("Cannot swap children.");
					addToList(child2, child1);
				} else if (child2.next == child1) {
					child1 = removeFromList(child1);
					if (child1 == null) throw new ArgumentError("Cannot swap children.");
					addToList(child1, child2);
				} else {
					var count:int = 0;
					for (var child:Object3D = childrenList; child != null; child = child.next) {
						if (child == child1) count++;
						if (child == child2) count++;
						if (count == 2) break;
					}
					if (count < 2) throw new ArgumentError("Cannot swap children.");
					//объект на который ссылается объект child1
					var nxt:Object3D = child1.next;
					//удаляем объект child1 из списка
					removeFromList(child1);
					//добавляем снова и заставляем ссылаться на объект child2
					addToList(child1, child2);
					//удаляем объект child2 из списка
					removeFromList(child2);
					//добавляем снова и заставляем ссылаться на объект nxt
					addToList(child2, nxt);
				}
			}
		}

		/**
		 * Меняет местами два дочерних объекта в списке по указанным позициям.
		 * @param index1 позиция первого дочернего объекта.
		 * @param index2 позиция второго дочернего объекта.
		 */
		public function swapChildrenAt(index1:int, index2:int):void {
			// проверка переданных в метод данных
			if (index1 < 0 || index2 < 0) throw new RangeError("The supplied index is out of bounds.");

			if (index1 != index2) {
				// находим объект в списке находящийся в позиции index1
				var i:int;
				var child1:Object3D = childrenList;
				for (i = 0; i < index1; i++) {
					if (child1 == null) throw new RangeError("The supplied index is out of bounds.");
					child1 = child1.next;
				}
				if (child1 == null) throw new RangeError("The supplied index is out of bounds.");
				
				// находим объект в списке находящийся в позиции index2
				var child2:Object3D = childrenList;
				for (i = 0; i < index2; i++) {
					if (child2 == null) throw new RangeError("The supplied index is out of bounds.");
					child2 = child2.next;
				}
				if (child2 == null) throw new RangeError("The supplied index is out of bounds.");
				
				// если объект child1 указывает на объект child2, или наоборот,
				// то сразу же удаляем один объект из списка и добавляем в позицию другого
				if (child1 != child2) {
					if (child1.next == child2) {
						removeFromList(child2);
						addToList(child2, child1);
					} else if (child2.next == child1) {
						removeFromList(child1);
						addToList(child1, child2);
					} else {
						//объект на который ссылается объект child1
						var nxt:Object3D = child1.next;
						//удаляем объект child1 из списка
						removeFromList(child1);
						//добавляем снова и заставляем ссылаться на объект child2
						addToList(child1, child2);
						//удаляем объект child2 из списка
						removeFromList(child2);
						//добавляем снова и заставляем ссылаться на объект nxt
						addToList(child2, nxt);
					}
				}
			}
		}

		/**
		 * Возвращает дочерний объект с заданным именем. 
		 * Если объектов с заданным именем несколько, возвратится первый попавшийся. 
		 * Если объект с заданным именем не содержится в контейнере, возвратится null.
		 * @param 	name имя дочернего объекта.
		 * @return 	дочерний объект с заданным именем.
		 */
		public function getChildByName(name:String):Object3D {
			// проверка переданных в метод данных
			if (name == null) throw new TypeError("Parameter name must be non-null.");
			// пробегаемся по списку детей текущего объекта и находим объект у которого имя
			// соответствует переданному в метод значению.
			for (var child:Object3D = childrenList; child != null; child = child.next) {
				if (child.name == name) return child;
			}
			return null;
		}

		/**
		 * Определяет, содержится ли указанный объект среди дочерних объектов текущего объекта.
		 * @param child дочерний объект.
		 * @return		true, если указанный объект является текущим объектом или одним из его потомков, в противном случае значение false.
		 */
		public function contains(child:Object3D):Boolean {
			// проверка переданных в метод данных
			if (child == null) throw new TypeError("Parameter child must be non-null.");
			// пробегаемся по всему списку, у каждого объекта вызываем метод contains()
			// передавая ему ссылку на указанный объект child.
			// Если один из детей текущего объекта окажется объектом child, возвращаем true
			if (child == this) return true;
			for (var object:Object3D = childrenList; object != null; object = object.next) {
				if (object.contains(child)) return true;
			}
			return false;
		}

		/** Возвращает количество дочерних объектов текущего объекта. */
		public function get numChildren():int {
			var num:int = 0;
			for (var current:Object3D = childrenList; current != null; current = current.next) num++;
			return num;
		}
		
		/**
		 * Добавляет объект в список детей текущего объекта.
		 * @param	child 	объект, который должен быть добавлен в список.
		 * @param	item 	объект, на который должен ссылаться добавляемый объект. 
		 */
		private function addToList(child:Object3D, item:Object3D = null):void {
			//добавляемый объект будет ссылаться на объект item
			child.next = item;
			//если список еще не был инициализирован
			if (item == childrenList) {
				//то первым в списке этого контейнера будет добавляемый объект
				childrenList = child;
			} else {
				///иначе, вставляем в список добавленный объект
				for (var current:Object3D = childrenList; current != null; current = current.next) {
					if (current.next == item) {
						current.next = child;
						break;
					}
				}
			}
		}
		
		/**
		 * Удаляет объект из списка детей текущего объекта.
		 * @param	child 	объект, который должен быть удален из списка.
		 * @private 
		 */
		alternativa3d function removeFromList(child:Object3D):Object3D {
			var prev:Object3D;
			for (var current:Object3D = childrenList; current != null; current = current.next) {
				//находим объект в списке, который должен быть удален
				if (current == child) {
					//если найденный объект не является первым в списке детей,
					//то заставляем предыдущий объект в списке ссылаться на объект на который ссылается
					//удаляемый объект.
					if (prev != null) {
						prev.next = current.next;
					} else {
						//если первый же объект в списке должен быть удален,
						//то теперь первым ребенком в списке детей текущего объета, будет объект
						//на который ссылался удаляемый объект
						childrenList = current.next;
					}
					//разрушаем связь удаляемого объекта с списком детей текущего объекта	
					current.next = null;
					return child;
				}
				prev = current;
			}
			return null;
		}
		
		/**
		 * Собирает ресурсы используемые данным объектом для того, чтобы в дальнейшем их можно было бы загрузить в контекст.
		 *
		 * @param hierarchy 	флаг указывающий на необходимость сбора ресурсов у дочерних объектов.
		 * @param resourceType 	тип ресурсов, которые должны быть собраны.
		 * @return 				вектор содержайщий собранные ресурсы.
		 * @see flash.display.Stage3D
		 */
		public function getResources(hierarchy:Boolean = false, resourceType:Class = null):Vector.<Resource> {
			//вектор в который будут записаны ссылки на ресурсы
			var res:Vector.<Resource> = new Vector.<Resource>();
			//объект Dictionary в который будут записаны ссылки на ресурсы
			var dict:Dictionary = new Dictionary();
			var count:int = 0;
			//собираем ресурсы
			fillResources(dict, hierarchy, resourceType);
			//копируем ресурсы из словаря в вектор
			for (var key:* in dict) {
				res[count++] = key as Resource;
			}
			return res;
		}

		/**
		 * Собирает ресурсы, которые должны быть загружены в Context3D.
		 * @param	resources	 объект Dictionary, в который будут записаны ссылки на собранные ресурсы.
		 * @param	hierarchy	 флаг указывающий на необходимость сбора ресурсов у дочерних объектов.
		 * @param	resourceType тип ресурсов, которые должны быть собраны.
		 * @private 
		 */
		alternativa3d function fillResources(resources:Dictionary, hierarchy:Boolean = false, resourceType:Class = null):void {
			//если ресурсы должны быть собраны также и у детей текущего объекта,
			//вызываем у каждого ребенка метод fillResources().
			//У объекта Object3D никакие ресурсы не собираются, потому-что он не имеет ни сурфейсов,
			//ни геометрии. В дочерних классах это метод переопределяется для сбора конкретных ресурсов.
			if (hierarchy) {
				for (var child:Object3D = childrenList; child != null; child = child.next) {
					child.fillResources(resources, hierarchy, resourceType);
				}
			}
		}

		/** 
		 * Обновляет текущую матрицу трансформации объекта transform
		 * и инвертированную матрицу трансформации inverseTransform.
		 * @private
		 */
		alternativa3d function composeTransforms():void {
			// собираем матрицу трансформации 
			var cosX:Number = Math.cos(_rotationX);
			var sinX:Number = Math.sin(_rotationX);
			var cosY:Number = Math.cos(_rotationY);
			var sinY:Number = Math.sin(_rotationY);
			var cosZ:Number = Math.cos(_rotationZ);
			var sinZ:Number = Math.sin(_rotationZ);
			var cosZsinY:Number = cosZ*sinY;
			var sinZsinY:Number = sinZ*sinY;
			var cosYscaleX:Number = cosY*_scaleX;
			var sinXscaleY:Number = sinX*_scaleY;
			var cosXscaleY:Number = cosX*_scaleY;
			var cosXscaleZ:Number = cosX*_scaleZ;
			var sinXscaleZ:Number = sinX*_scaleZ;
			transform.a = cosZ*cosYscaleX;
			transform.b = cosZsinY*sinXscaleY - sinZ*cosXscaleY;
			transform.c = cosZsinY*cosXscaleZ + sinZ*sinXscaleZ;
			transform.d = _x;
			transform.e = sinZ*cosYscaleX;
			transform.f = sinZsinY*sinXscaleY + cosZ*cosXscaleY;
			transform.g = sinZsinY*cosXscaleZ - cosZ*sinXscaleZ;
			transform.h = _y;
			transform.i = -sinY*_scaleX;
			transform.j = cosY*sinXscaleY;
			transform.k = cosY*cosXscaleZ;
			transform.l = _z;
			// собираем инвертированную матрицу трансформации
			var sinXsinY:Number = sinX*sinY;
			cosYscaleX = cosY/_scaleX;
			cosXscaleY = cosX/_scaleY;
			sinXscaleZ = -sinX/_scaleZ;
			cosXscaleZ = cosX/_scaleZ;
			inverseTransform.a = cosZ*cosYscaleX;
			inverseTransform.b = sinZ*cosYscaleX;
			inverseTransform.c = -sinY/_scaleX;
			inverseTransform.d = -inverseTransform.a*_x - inverseTransform.b*_y - inverseTransform.c*_z;
			inverseTransform.e = sinXsinY*cosZ/_scaleY - sinZ*cosXscaleY;
			inverseTransform.f = cosZ*cosXscaleY + sinXsinY*sinZ/_scaleY;
			inverseTransform.g = sinX*cosY/_scaleY;
			inverseTransform.h = -inverseTransform.e*_x - inverseTransform.f*_y - inverseTransform.g*_z;
			inverseTransform.i = cosZ*sinY*cosXscaleZ - sinZ*sinXscaleZ;
			inverseTransform.j = cosZ*sinXscaleZ + sinY*sinZ*cosXscaleZ;
			inverseTransform.k = cosY*cosXscaleZ;
			inverseTransform.l = -inverseTransform.i*_x - inverseTransform.j*_y - inverseTransform.k*_z;
			transformChanged = false;
		}

		/** Вычисляет, должен ли текущий объект рендериться или пропускаться при обходе. @private */
		alternativa3d function calculateVisibility(camera:Camera3D):void {}

		/** Вычисляет, какие дети текущего объекта должны быть визуализированы а какие нет. @private */
		alternativa3d function calculateChildrenVisibility(camera:Camera3D):void {
			for (var child:Object3D = childrenList; child != null; child = child.next) {
				//если объект видимый, то продолжаем обрабатывать его.
				//Если невидимый, то понятно что его рендерить не нужно.
				if (child.visible) {
					// обновляем матрицу трансформации объекта, если требуется.
					if (child.transformChanged) child.composeTransforms();
					// вычисляем матрицу для конвертирования координат камеры в локальные координаты объекта
					child.cameraToLocalTransform.combine(child.inverseTransform, cameraToLocalTransform);
					// вычисляем матрицу для конвертирования локальных координат объекта в координаты камеры
					child.localToCameraTransform.combine(localToCameraTransform, child.transform);
					// если у объекта имеется баундбокс
					if (child.boundBox != null) {
						//рассчитываем фрустум камеры, перенося его в пространство объекта 
						camera.calculateFrustum(child.cameraToLocalTransform);
						//проверяем баундбокс на пересечение с фрустумом камеры.
						// В свойство culling записывается результат вычилений.
						// 0  == баундбокс объекта полностью находится в пирамиде видимости камеры
						// 2  == баундбокс объекта пересекается c дальней плоскостью пирамиды видимости камеры
						// 4  == баундбокс объекта пересекается c левой плоскостью пирамиды видимости камеры
						// 8  == баундбокс объекта пересекается c правой плоскостью пирамиды видимости камеры
						// 16 == баундбокс объекта пересекается c верхней плоскостью пирамиды видимости камеры
						// 32 == баундбокс объекта пересекается c нижней плоскостью пирамиды видимости камеры
						// 48 == баундбокс объекта пересекается c ближней плоскостью пирамиды видимости камеры
						// 63 == баундбокс объекта полностью находится в пирамиде видимости камеры
						// -1 == баундбокс объекта полностью не находится в пирамиде видимости камеры
						child.culling = child.boundBox.checkFrustumCulling(camera.frustum, 63);
					} else {
						//если баундбокса у объекта нет, считаем такой объект как полностью находящийся в парамиде видимости камеры
						child.culling = 63;
					}

					// делаем дополнительные проверки, так должен ли все таки рендериться объект child
					if (child.culling >= 0) child.calculateVisibility(camera);
					// узнаём, какие из детей объекта child должны рендериться
					if (child.childrenList != null) child.calculateChildrenVisibility(camera);
				}
			}
		}

		/**
		 * Собирает ресурсы необходимые для рендеринга текущего объекта. 
		 * @param	camera		 	камера.
		 * @param	lights			источники света, воздействующие на объект.
		 * @param	lightsLength	количество источников света.
		 * @private
		 */
		alternativa3d function collectDraws(camera:Camera3D, lights:Vector.<Light3D>, lightsLength:int):void {}

		/**
		 * Собирает ресурсы необходимые для рендеринга детей текущего объекта. 
		 * @param	camera			камера.
		 * @param	lights			источники света, воздействующие на объект.
		 * @param	lightsLength	количество источников света.
		 * @private
		 */
		alternativa3d function collectChildrenDraws(camera:Camera3D, lights:Vector.<Light3D>, lightsLength:int):void {
			var i:int;
			var light:Light3D;
			//пробегаемся по списку детей текущего объекта
			for (var child:Object3D = childrenList; child != null; child = child.next) {
				//если объект видимый, то продолжаем обрабатывать его.
				//Если невидимый, то понятно что его рендерить не нужно.
				if (child.visible) {
					// если объект child находится в фрустуме камеры и его не перекрывают окклюдеры, то продолжаем его обрабатывать
					if (child.culling >= 0 && (child.boundBox == null || camera.occludersLength == 0 || !child.boundBox.checkOcclusion(camera.occluders, camera.occludersLength, child.localToCameraTransform))) {
						// проверяем лучи-события мыши на пересечение с баундбоксом объекта, результат
						// проверки записываем в переменную listening.
						// true == пересечение лучей с баундбоксом найдено , false == не найдено.
						if (child.boundBox != null) {
							//вычисляем лучи-события мыши
							camera.calculateRays(child.cameraToLocalTransform);
							//вычисляем пересечение лучей с баундбоксом
							child.listening = child.boundBox.checkRays(camera.origins, camera.directions, camera.raysLength);
						} else {
							child.listening = true;
						}
						// если на объект должны воздействовать источники света
						if (lightsLength > 0 && child.useLights) {
							if (child.boundBox != null) {
								var childLightsLength:int = 0;
								for (i = 0; i < lightsLength; i++) {
									light = lights[i];
									// вычисляем матрицу для конвертирования координат из пространства источника света
									// в пространство объекта child
									light.lightToObjectTransform.combine(child.cameraToLocalTransform, light.localToCameraTransform);
									// определяем количество источников света оказывающих влияние на текущий объект child
									if (light.boundBox == null || light.checkBound(child)) {
										camera.childLights[childLightsLength] = light;
										childLightsLength++;
									}
								}
								child.collectDraws(camera, camera.childLights, childLightsLength);
							} else {
								// вычисляем матрицу для конвертирования координат из пространства источника света
								// в пространство объекта child
								for (i = 0; i < lightsLength; i++) {
									light = lights[i];
									light.lightToObjectTransform.combine(child.cameraToLocalTransform, light.localToCameraTransform);
								}
								child.collectDraws(camera, lights, lightsLength);
							}
						} else {
							child.collectDraws(camera, null, 0);
						}
						// если включен дебаг режим камеры, и включена отрисовка баундбоксов, то рисуем баундбокс объекта child (объект Wireframe) 
						if (camera.debug && child.boundBox != null && (camera.checkInDebug(child) & Debug.BOUNDS)) Debug.drawBoundBox(camera, child.boundBox, child.localToCameraTransform);
					}
					// собираем ресуры у детей текущего объекта
					if (child.childrenList != null) child.collectChildrenDraws(camera, lights, lightsLength);
				}
			}
		}

		/**
		 * Собирает геометрию текущего объекта для проверки пересечения коллайдера с ней.
		 * @param	collider		коллайдер с которым будет осуществляться проверка на пересечение. 
		 * @param	excludedObjects	ассоциативный массив, ключами которого являются экземпляры Object3D и его наследников.
		 * 							Объекты, содержащиеся в этом массиве будут исключены из проверки.
		 * @private
		 */
		alternativa3d function collectGeometry(collider:EllipsoidCollider, excludedObjects:Dictionary):void {}

		/**
		 * Собирает геометрию детей текущего объекта для проверки пересечения коллайдера с ней.
		 * @param	collider		 коллайдер с которым будет осуществляться проверка на пересечение. 
		 * @param	excludedObjects  ассоциативный массив, ключами которого являются экземпляры Object3D и его наследников.
		 * 							 Объекты, содержащиеся в этом массиве будут исключены из проверки.
		 * @private
		 */
		alternativa3d function collectChildrenGeometry(collider:EllipsoidCollider, excludedObjects:Dictionary):void {
			//пробегаемся по списку детей текущего объекта
			for (var child:Object3D = childrenList; child != null; child = child.next) {
				//если проверка пересечения коллайдера с объектом child может быть произведена
				if (excludedObjects == null || !excludedObjects[child]) {
					// обновляем матрицу трансформации объекта, если требуется
					if (child.transformChanged) child.composeTransforms();
					// вычисляем матрицу для конвертирования координат коллайдера в локальные координаты объекта
					child.globalToLocalTransform.combine(child.inverseTransform, globalToLocalTransform);
					// проверяем пересечение сферы-коллайдера с баундбоксом объекта
					var intersects:Boolean = true;
					if (child.boundBox != null) {
						collider.calculateSphere(child.globalToLocalTransform);
						intersects = child.boundBox.checkSphere(collider.sphere);
					}
					// если пересечение коллайдера с баундбоксом было найдено, или у объекта child не был
					// определен баундбокс, осуществляем проверку пересечения коллайдера с геометрией объекта
					if (intersects) {
						// вычисляем матрицу для конвертирования локальных координат объекта в координаты коллайдера
						child.localToGlobalTransform.combine(localToGlobalTransform, child.transform);
						//добавляем в коллайдер ссылку на геометрию объекта child, с которой коллайдер будет осуществлять
						//проверку на пересечение
						child.collectGeometry(collider, excludedObjects);
					}
					// проверяем пересечение коллайдера с детьми объекта child
					if (child.childrenList != null) child.collectChildrenGeometry(collider, excludedObjects);
				}
			}
		}

		/** @private */
		alternativa3d function setTransformConstants(drawUnit:DrawUnit, surface:Surface, vertexShader:Linker, camera:Camera3D):void {}

		/**
		 * Возвращает копию объекта.
		 * @return копия объекта.
		 */
		public function clone():Object3D {
			var res:Object3D = new Object3D();
			res.clonePropertiesFrom(this);
			return res;
		}

		/**
		 * Копирует базовые свойства. Метод вызывается внутри метода clone().
		 * @param source объект, с которого копируются базовые свойства.
		 */
		protected function clonePropertiesFrom(source:Object3D):void {
			userData = source.userData;
			
			name = source.name;
			visible = source.visible;
			mouseEnabled = source.mouseEnabled;
			mouseChildren = source.mouseChildren;
			doubleClickEnabled = source.doubleClickEnabled;
			useHandCursor = source.useHandCursor;
			boundBox = source.boundBox ? source.boundBox.clone() : null;
			_x = source._x;
			_y = source._y;
			_z = source._z;
			_rotationX = source._rotationX;
			_rotationY = source._rotationY;
			_rotationZ = source._rotationZ;
			_scaleX = source._scaleX;
			_scaleY = source._scaleY;
			_scaleZ = source._scaleZ;
			//пробегаемся по списку детей переданного объекта, и копируем их в текущий объект
			for (var child:Object3D = source.childrenList, lastChild:Object3D; child != null; child = child.next) {
				var newChild:Object3D = child.clone();
				
				if (childrenList != null)
					lastChild.next = newChild;
				else
					childrenList = newChild;
					
				lastChild = newChild;
				newChild._parent = this;
			}
		}

		/**
		 * Возвращает строковое представление текущего объекта.
		 * @return строковое представление объекта.
		 */
		public function toString():String {
			var className:String = getQualifiedClassName(this);
			return "[" + className.substr(className.indexOf("::") + 2) + " " + name + "]";
		}
	}
}