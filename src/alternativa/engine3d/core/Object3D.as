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
	 * ������������, ����� ������ ����������� � ������ �����. ��� ������� ����������� ���������� 
	 * ��������: Object3D.addChild(), Object3D.addChildAt().
	 *
	 * @see #addChild()
	 * @see #addChildAt()
	 *
	 * @eventType alternativa.engine3d.core.events.Event3D.ADDED
	 */
	[Event(name="added",type="alternativa.engine3d.core.events.Event3D")]

	/**
	 * ������������ ����� ��������� ������� �� ������ �����. ��� ������� ���������� ��� ������ ������:
	 * Object3D.removeChild() � Object3D.removeChildAt().
	 *
	 * @see #removeChild()
	 * @see #removeChildAt()
	 * @eventType alternativa.engine3d.core.events.Event3D.REMOVED
	 */
	[Event(name="removed",type="alternativa.engine3d.core.events.Event3D")]

	/**
	 * ������� ����������� ����� ������������ ��������������� �������� � ��������� �����
	 * ������ ���� ��� ����� � ��� �� ��������. ����� �������� � ����������� ������ �����
	 * ����������� ����� ������ �������.
	 *
	 * @eventType alternativa.engine3d.events.MouseEvent3D.CLICK
	 */
	[Event (name="click", type="alternativa.engine3d.core.events.MouseEvent3D")]

	/**
	 * ������� ����������� ����� ������������ ��������������� 2 ���� �������� � ��������� �����
	 * ������ ���� ��� ����� � ��� �� ��������. ������� ��������� ������ ���� ����� ����� ������
	 * � ������ ������ ����������� � �������� � ������� ��������� ��������.
	 *
	 * @eventType alternativa.engine3d.events.MouseEvent3D.DOUBLE_CLICK
	 */
	[Event (name="doubleClick", type="alternativa.engine3d.core.events.MouseEvent3D")]

	/**
	 * ������� ����������� ����� ������������ �������� ����� ������ ���� ��� ��������.
	 * @eventType alternativa.engine3d.events.MouseEvent3D.MOUSE_DOWN
	 */
	[Event (name="mouseDown", type="alternativa.engine3d.core.events.MouseEvent3D")]

	/**
	 * ������� ����������� ����� ������������ ��������� ����� ������ ���� ��� ��������.
	 * @eventType alternativa.engine3d.events.MouseEvent3D.MOUSE_UP
	 */
	[Event (name="mouseUp", type="alternativa.engine3d.core.events.MouseEvent3D")]

	/**
	 * ������� ����������� ����� ������������ ������� ������ ���� �� ������.
	 * @eventType alternativa.engine3d.events.MouseEvent3D.MOUSE_OVER
	 */
	[Event (name="mouseOver", type="alternativa.engine3d.core.events.MouseEvent3D")]

	/**
	 * ������� ����������� ����� ������������ ������ ������ ���� � �������.
	 * @eventType alternativa.engine3d.events.MouseEvent3D.MOUSE_OUT
	 */
	[Event (name="mouseOut", type="alternativa.engine3d.core.events.MouseEvent3D")]

	/**
	 * ������� ����������� ����� ������������ ������� ������ ���� �� ������.
	 * @eventType alternativa.engine3d.events.MouseEvent3D.ROLL_OVER
	 */
	[Event (name="rollOver", type="alternativa.engine3d.core.events.MouseEvent3D")]

	/**
	 * ������� ����������� ����� ������������ ������ ������ ���� � �������.
	 * @eventType alternativa.engine3d.events.MouseEvent3D.ROLL_OUT
	 */
	[Event (name="rollOut", type="alternativa.engine3d.core.events.MouseEvent3D")]

	/**
	 * ������� ����������� ����� ������������ ���������� ������ ���� ��� ��������.
	 * @eventType alternativa.engine3d.events.MouseEvent3D.MOUSE_MOVE
	 */
	[Event (name="mouseMove", type="alternativa.engine3d.core.events.MouseEvent3D")]

	/**
	 * ������� ����������� ����� ������������ ������� ������ ���� ��� ��������.
	 * @eventType alternativa.engine3d.events.MouseEvent3D.MOUSE_WHEEL
	 */
	[Event (name="mouseWheel", type="alternativa.engine3d.core.events.MouseEvent3D")]

	/**
	 * ������� ����� ��� ���� ���������� ��������. � ������ Object3D ���� �������� �������������,
	 * ������������ ��� ��������� � ������������, �������� boundBox,����������� ������� ������������,
	 * � ������� ����������� ������ ���������� ������ � ���� �������������� ���������������. ��������� 
	 * ������������� ������������ ����� ������ �������� ����������� ����� � �������� ����������� ���� ����������.
	 * � ������� �� ���������� ������ Alternativa3D, ��������� ����� ������ ����� ��������� ��������� �����,
	 * �� ���� � ��������� ������ �� ����� ��������� � ���� ����������. ��� �� ��������� � �� ���� ����������� Object3D.
	 *
	 * @see alternativa.engine3d.objects.Mesh
	 * @see alternativa.engine3d.core.BoundBox
	 */
	public class Object3D implements IEventDispatcher {

		/** ������������ ������ ������������, �������� � ��������. */
		public var userData:Object;

		/** ����, ������������ ����� �� ���� ������ �������������� ��������� ����� ��� ���. @private */ 
		public var useShadow:Boolean = true;

		/** 
		 * ������� �������������, ��� ����������� �������������, �������������� � ��������� ������� ��� 
		 * �������� ��������� ��������.
		 * @private 
		 */
		alternativa3d static const trm:Transform3D = new Transform3D();

		/** ��� �������. */
		public var name:String;

		/** ���� ��������� �������. */
		public var visible:Boolean = true;

		/** ����������, �������� �� ������ ��������� ����. �������� �� ��������� � true. ������ ��������� flash.display.InteractiveObject. */
		public var mouseEnabled:Boolean = true;
		
		/**
		 * ����������, ������� �� ������� ����� ��������� ������� � ������� ����. ����
		 * false, �� � �������� target ������� ����� ��� ���������,
		 * ���������� �� ��� �����������. �������� �� ��������� � true.
		 */
		public var mouseChildren:Boolean = true;
		
		/**
		 * ����������, �������� �� ������ ������� doubleClick. �������� �� ��������� � false. 
		 * ����������: ��� ��������� ������� doubleClick ���������� ���������� � true �������� doubleClickEnabled 
		 * �������� Stage.
		 */
		public var doubleClickEnabled:Boolean = false;
		
		/** ���������� ��������, ������������, ������ �� ������������ ��������� "����" ��� ��������� ��������� ����. */
		public var useHandCursor:Boolean = false;
		
		/** ������� �������. */
		public var boundBox:BoundBox;

		/** ������� ������� �� ��� X ������������ ��������� ��������� ������������� Object3D. @private */
		alternativa3d var _x:Number = 0;
		/** ������� ������� �� ��� Y ������������ ��������� ��������� ������������� Object3D. @private */
		alternativa3d var _y:Number = 0;
		/** ������� ������� �� ��� Z ������������ ��������� ��������� ������������� Object3D. @private */
		alternativa3d var _z:Number = 0;
		/** ��������������� ������ ��� �������� ������� �������. @private */
		alternativa3d var _pos:Vector3D = new Vector3D();
		/** ���� �������� ������� ������ ��� X. ����������� � ��������. @private */
		alternativa3d var _rotationX:Number = 0;
		/** ���� �������� ������� ������ ��� Y. ����������� � ��������. @private */
		alternativa3d var _rotationY:Number = 0;
		/** ���� �������� ������� ������ ��� Z. ����������� � ��������. @private */
		alternativa3d var _rotationZ:Number = 0;
		/** ������� 3D �������. @private */
		alternativa3d var _eulers : Vector3D = new Vector3D();
		/** ����������� ��������������� ������� �� ��� X. @private */
		alternativa3d var _scaleX:Number = 1;
		/** ����������� ��������������� ������� �� ��� Y. @private */
		alternativa3d var _scaleY:Number = 1;
		/** ����������� ��������������� ������� �� ��� Z. @private */
		alternativa3d var _scaleZ:Number = 1;
		/** @private */
		alternativa3d var _m:Matrix3D = new Matrix3D();

		/** ������ �� ������, ������� �������� ��������� �������� �������. @private */
		alternativa3d var _parent:Object3D;
		/** ������ ����� �������� �������. @private */
		alternativa3d var childrenList:Object3D;
		/** ������ �� ��������� ������ � ������. @private */
		alternativa3d var next:Object3D;
		/** ������� ������������� �������. @private */
		alternativa3d var transform:Transform3D = new Transform3D();
		/** ��������������� ������� ������������� �������. @private */
		alternativa3d var inverseTransform:Transform3D = new Transform3D();
		/** ���� � ������� �������� ������������, ��������� �������� ������� ������������� ��� ���. @private */
		alternativa3d var transformChanged:Boolean = true;
		/** ������� ��� ��������������� ��������� ������ � ��������� ���������� �������. @private */
		alternativa3d var cameraToLocalTransform:Transform3D = new Transform3D();
		/** ������� ��� ��������������� ��������� ��������� ������� � ���������� ������. @private */
		alternativa3d var localToCameraTransform:Transform3D = new Transform3D();
		/** ������� ��� ��������������� ��������� ��������� ������� � ���������� ����������. @private */
		alternativa3d var localToGlobalTransform:Transform3D = new Transform3D();
		/** ������� ��� ��������������� ��������� ���������� � ��������� ���������� �������. @private */
		alternativa3d var globalToLocalTransform:Transform3D = new Transform3D();
		/** �������� �������� ��������� �������� ����������� ���������� ������� � ��������� ������. @private */
		alternativa3d var culling:int;
		/** �������� �������� ��������� �������� ����������� ������� � ������-��������� ����. @private */
		alternativa3d var listening:Boolean;
		/** ���������� �� �������� ������� �� ������. ������������ �������� LOD ��� �����������, ����� ������ ���������. @private */
		alternativa3d var distance:Number;
		/** ������, ������� ����� ������� �������, ���������� ��� ����������� ������������� ������� � ������� ��� ����������� �����. @private */
		alternativa3d var bubbleListeners:Object;
		/** ������, ������� ����� ������� �������, ���������� ��� ����������� ������������� ������� � ���� �������. @private */
		alternativa3d var captureListeners:Object;
		/** @private */
		alternativa3d var transformProcedure:Procedure;
		/** @private */
		alternativa3d var deltaTransformProcedure:Procedure;

		/** ������� ������� �� ��� X ������������ ��������� ��������� ������������� Object3D. */
		public function get x():Number {return _x;}
		public function set x(value:Number):void {
			if (_x != value) {
				_x = value;
				//�������, ��� ������� ������������� ������� ������� ��������
				transformChanged = true;
			}
		}

		/** ������� ������� �� ��� Y ������������ ��������� ��������� ������������� Object3D. */
		public function get y():Number {return _y;}
		public function set y(value:Number):void {
			if (_y != value) {
				_y = value;
				//�������, ��� ������� ������������� ������� ������� ��������
				transformChanged = true;
			}
		}

		/** ������� ������� �� ��� Z ������������ ��������� ��������� ������������� Object3D. */
		public function get z():Number {return _z;}
		public function set z(value:Number):void {
			if (_z != value) {
				_z = value;
				//�������, ��� ������� ������������� ������� ������� ��������
				transformChanged = true;
			}
		}
		
		/** ������� 3D �������. */
		public function get position() : Vector3D {
			matrix.copyColumnTo(3, _pos);
			return _pos.clone();
		}

		public function set position(value : Vector3D) : void {
			x = value.x;
			y = value.y;
			z = value.z;
		}

		/** ���� �������� ������� ������ ��� X. ����������� � ��������. */
		public function get rotationX():Number {return _rotationX * MathConsts.RADIANS_TO_DEGREES;}
		public function set rotationX(value:Number):void {
			if (rotationX != value) {
				_rotationX = value * MathConsts.DEGREES_TO_RADIANS;;
				transformChanged = true;
			}
		}

		/** ���� �������� ������� ������ ��� Y. ����������� � ��������. */
		public function get rotationY():Number {return _rotationY * MathConsts.RADIANS_TO_DEGREES;}
		public function set rotationY(value:Number):void {
			if (rotationY != value) {
				_rotationY = value * MathConsts.DEGREES_TO_RADIANS;
				transformChanged = true;
			}
		}

		/** ���� �������� ������� ������ ��� Z. ����������� � ��������. */
		public function get rotationZ():Number {return _rotationZ * MathConsts.RADIANS_TO_DEGREES;}
		public function set rotationZ(value:Number):void {
			if (rotationZ != value) {
				_rotationZ = value * MathConsts.DEGREES_TO_RADIANS;
				transformChanged = true;
			}
		}
		
		/** ������� 3D �������. ��� ����� ������������ ������ <code>Vector3D</code> ���������� ���� �������� �� ���� x, y � z. */
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

		/** ����������� ��������������� ������� �� ��� X. */
		public function get scaleX():Number { return _scaleX; }
		public function set scaleX(value:Number):void {
			if (_scaleX != value) {
				_scaleX = value;
				transformChanged = true;
			}
		}

		/** ����������� ��������������� ������� �� ��� Y. */
		public function get scaleY():Number {return _scaleY;}
		public function set scaleY(value:Number):void {
			if (_scaleY != value) {
				_scaleY = value;
				transformChanged = true;
			}
		}

		/** ����������� ��������������� ������� �� ��� Z. */
		public function get scaleZ():Number {return _scaleZ;}
		public function set scaleZ(value:Number):void {
			if (_scaleZ != value) {
				_scaleZ = value;
				transformChanged = true;
			}
		}
		
		/**
		 * ���������� ������������ ������ �� ���� ���� ����.
		 * @param value �������� ���������������.
		 */
		public function scale(value : Number) : void {
			scaleX *= value;
			scaleY *= value;
			scaleZ *= value;
		}
		
		/** ������� ������������ ����� �� �������.  */
		public function get forwardVector():Vector3D {return Matrix3DUtils.getForward(matrix);}
		/**  ������� ������������ ������ �� �������. */
		public function get rightVector():Vector3D {return Matrix3DUtils.getRight(matrix);}
		/** ������� ������������ ����� �� �������.  */
		public function get upVector():Vector3D { return Matrix3DUtils.getUp(matrix); }
		
		/** ������� ������������ ����� �� �������.  */
		public function get backVector():Vector3D {
			var director:Vector3D = Matrix3DUtils.getForward(matrix);
			director.negate();
			return director;
		}
		
		/** ������� ������������ ����� �� �������.  */
		public function get leftVector():Vector3D {
			var director:Vector3D = Matrix3DUtils.getRight(matrix);
			director.negate();
			return director;
		}
		
		/** ������� ������������ ���� �� �������.  */
		public function get downVector():Vector3D {
			var director:Vector3D = Matrix3DUtils.getUp(matrix);
			director.negate();
			return director;
		}
		
		/**
		 * ���������� 3D ������ ������ ����� ��� ��������� ��� z.
		 * @param	distance	����� �����������.
		 */
		public function moveForward(distance : Number) : void {
			translateLocal(Vector3D.Y_AXIS, distance);
		}

		/**
		 * ���������� 3D ������ ����� ����� ��� ��������� ��� z.
		 * @param	distance	����� �����������.
		 */
		public function moveBackward(distance : Number) : void {
			translateLocal(Vector3D.Y_AXIS, -distance);
		}

		/**
		 * ���������� 3D ������ ����� ����� ��� ��������� ��� x.
		 * @param	distance	����� �����������.
		 */
		public function moveLeft(distance : Number) : void {
			translateLocal(Vector3D.X_AXIS, -distance);
		}

		/**
		 * ���������� 3D ������ ������ ����� ��� ��������� ��� x.
		 * @param	distance	����� �����������.
		 */
		public function moveRight(distance : Number) : void {
			translateLocal(Vector3D.X_AXIS, distance);
		}

		/**
		 * ���������� 3D ������ ������ ����� ��� ��������� ��� y.
		 * @param	distance	����� �����������.
		 */
		public function moveUp(distance : Number) : void {
			translateLocal(Vector3D.Z_AXIS, distance);
		}

		/**
		 * ���������� 3D ������ ����� ����� ��� ��������� ��� y.
		 * @param	distance	����� �����������.
		 */
		public function moveDown(distance : Number) : void {
			translateLocal(Vector3D.Z_AXIS, -distance);
		}

		/**
		 * ���������� 3D ������ � ��������� �����.
		 * @param	dx		���������� �� ��� x.
		 * @param	dy		���������� �� ��� y.
		 * @param	dz		���������� �� ��� z.
		 */
		public function moveTo(dx : Number, dy : Number, dz : Number) : void {
			x = dx;
			y = dy;
			z = dz;
		}
		
		/**
		 * ���������� 3D-������ ����� ������� �� ������������ �����.
		 * @param	axis		������, ������������ ����������� ��������.
		 * @param	distance	����� �����������.
		 */
		public function translate(axis : Vector3D, distance : Number) : void {
			var x : Number = axis.x, y : Number = axis.y, z : Number = axis.z;
			var len : Number = distance / Math.sqrt(x* x + y * y + z * z);

			this.x += x * len;
			this.y += y * len;
			this.z += z * len;
		}

		/**
		 * ���������� 3D-������ ����� ������� �� ������������ �����.
		 * @param	axis		������, ������������ ����������� ��������.
		 * @param	distance	����� �����������.
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
		 * ������������ 3D-������ ������ ��������� ��� x.
		 * @param	angle		�������� �������� � ��������.
		 */
		public function pitch(angle : Number) : void {rotate(Vector3D.X_AXIS, angle);}

		/**
		 * ������������ 3D-������ ������ ��������� ��� y.
		 * @param	angle		�������� �������� � ��������.
		 */
		public function yaw(angle : Number) : void {rotate(Vector3D.Z_AXIS, angle);}

		/**
		 * ������������ 3D-������ ������ ��������� ��� z.
		 * @param	angle		�������� �������� � ��������.
		 */
		public function roll(angle : Number) : void { rotate(Vector3D.Y_AXIS, angle); }
		
		/**
		 * ������������ 3D-������.
		 * @param	ax		���� �������� � �������� ������ ��� x.
		 * @param	ay		���� �������� � �������� ������ ��� y.
		 * @param	az		���� �������� � �������� ������ ��� z.
		 */
		public function rotateTo(ax : Number, ay : Number, az : Number) : void {
			rotationX = ax;
			rotationY = ay;
			rotationZ = az;
		}

		/**
		 * ������������ 3D-������ ������ ��������� ��� �� ��������� ����.
		 * @param	axis		������, ������������ ��� ��������
		 * @param	angle		���� �������� � ��������.
		 */
		public function rotate(axis : Vector3D, angle : Number) : void {
			_m = matrix;
			_m.prependRotation(angle, axis);
			matrix = _m;
		}

		/** ������ Matrix3D, ���������� ��������, �������� �� ���������������, ������� � ����������� �������. */
		public function get matrix():Matrix3D {
			//����� ��������� ������� Matrix3D �� �������, ���� ��� ���������, ������� ������� ������������� transform ������ Transform3D
			if (transformChanged) composeTransforms();
			return new Matrix3D(Vector.<Number>([transform.a, transform.e, transform.i, 0, transform.b, transform.f, transform.j, 0, transform.c, transform.g, transform.k, 0, transform.d, transform.h, transform.l, 1]));
		}
		public function set matrix(value:Matrix3D):void {
			//��������� ������� �� ��� ������
			var v:Vector.<Vector3D> = value.decompose();
			//�������
			var t:Vector3D = v[0];
			//�������
			var r:Vector3D = v[1];
			//�������
			var s:Vector3D = v[2];
			//��������� ���������� ����������
			_x = t.x;
			_y = t.y;
			_z = t.z;
			_rotationX = r.x;
			_rotationY = r.y;
			_rotationZ = r.z;
			_scaleX = s.x;
			_scaleY = s.y;
			_scaleZ = s.z;
			//� ������������ ���������� ������� �������������
			transformChanged = true;
		}

		/**
		 * ������������ ����� ����������� ���� � ��������.
		 * @param origin 	������ ����.
		 * @param direction ����������� ����.
		 * @return 			��������� ������ ����������� � ������ RayIntersectionData. ���� ����������� ���, ����� ��������� null.
		 * 
		 * @see RayIntersectionData
		 * @see alternativa.engine3d.objects.Sprite3D
		 * @see alternativa.engine3d.core.Camera3D#calculateRay()
		 */
		public function intersectRay(origin:Vector3D, direction:Vector3D):RayIntersectionData {
			return intersectRayChildren(origin, direction);
		}

		/**
		 * ���� ����������� ���� � ������ �������� �������.
		 * @param	origin		������ ����.
		 * @param	direction	����������� ����.
		 * @return				��������� ������ ����������� � ������ RayIntersectionData.
		 * @private
		 */
		alternativa3d function intersectRayChildren(origin:Vector3D, direction:Vector3D):RayIntersectionData {
			var minTime:Number = 1e22;
			var minData:RayIntersectionData = null;
			var childOrigin:Vector3D;
			var childDirection:Vector3D;
			//����������� �� ���� ����� �������� ������� 
			for (var child:Object3D = childrenList; child != null; child = child.next) {
				//���� ���������� ��������� ������� �������������
				if (child.transformChanged) child.composeTransforms();
				//�������������� ��������������� �������, ���� ��� �� ���� ���������������� �����
				if (childOrigin == null) {
					childOrigin = new Vector3D();
					childDirection = new Vector3D();
				}
				//��������� ������ � ����������� ���� � ������������ ��������� ������� child
				childOrigin.x = child.inverseTransform.a*origin.x + child.inverseTransform.b*origin.y + child.inverseTransform.c*origin.z + child.inverseTransform.d;
				childOrigin.y = child.inverseTransform.e*origin.x + child.inverseTransform.f*origin.y + child.inverseTransform.g*origin.z + child.inverseTransform.h;
				childOrigin.z = child.inverseTransform.i*origin.x + child.inverseTransform.j*origin.y + child.inverseTransform.k*origin.z + child.inverseTransform.l;
				childDirection.x = child.inverseTransform.a*direction.x + child.inverseTransform.b*direction.y + child.inverseTransform.c*direction.z;
				childDirection.y = child.inverseTransform.e*direction.x + child.inverseTransform.f*direction.y + child.inverseTransform.g*direction.z;
				childDirection.z = child.inverseTransform.i * direction.x + child.inverseTransform.j * direction.y + child.inverseTransform.k * direction.z;
				//��������� ����������� �������, � �������� Mesh � LOD ����������� ����������� � ����������.
				//� ���� ������� ����� intersectRay ������������� ��� ���������� ���� ����������������
				var data:RayIntersectionData = child.intersectRay(childOrigin, childDirection);
				if (data != null && data.time < minTime) {
					minData = data;
					minTime = data.time;
				}
			}
			return minData;
		}

		/** ������ Matrix3D, �������������� ������������ ������� �������������� ������� � ���� ��� ������������ ��������, ������ �� ��������� ������. */
		public function get concatenatedMatrix():Matrix3D {
			if (transformChanged) composeTransforms();
			trm.copy(transform);
			var root:Object3D = this;
			//����������� �� ���� ��������� �������� ������� � �����������
			//��� ������� �������������.
			while (root.parent != null) {
				root = root.parent;
				if (root.transformChanged) root.composeTransforms();
				trm.append(root.transform);
			}
			return new Matrix3D(Vector.<Number>([trm.a, trm.e, trm.i, 0, trm.b, trm.f, trm.j, 0, trm.c, trm.g, trm.k, 0, trm.d, trm.h, trm.l, 1]));
		}

		/**
		 * ����������� ����� �� ��������� ��������� � ����������.
		 * @param point ����� � ��������� ����������� �������.
		 * @return 		����� � ���������� ������������.
		 */
		public function localToGlobal(point:Vector3D):Vector3D {
			if (transformChanged) composeTransforms();
			// ����������� ��� ������� ������������� ������ �� ��������� ������
			trm.copy(transform);
			var root:Object3D = this;
			while (root.parent != null) {
				root = root.parent;
				if (root.transformChanged) root.composeTransforms();
				trm.append(root.transform);
			}
			//��������� ����� � ������������ ���������� ������� ������������ 
			var res:Vector3D = new Vector3D();
			res.x = trm.a*point.x + trm.b*point.y + trm.c*point.z + trm.d;
			res.y = trm.e*point.x + trm.f*point.y + trm.g*point.z + trm.h;
			res.z = trm.i*point.x + trm.j*point.y + trm.k*point.z + trm.l;
			return res;
		}

		/**
		 * ����������� ����� �� ���������� ������� ��������� � ��������� ���������� �������.
		 * @param point ����� � ���������� ������������.
		 * @return 		����� � ��������� ����������� �������.
		 */
		public function globalToLocal(point:Vector3D):Vector3D {
			if (transformChanged) composeTransforms();
			// ����������� ��� ��������������� ������� ������������� ������ �� ��������� ������
			trm.copy(inverseTransform);
			var root:Object3D = this;
			while (root.parent != null) {
				root = root.parent;
				if (root.transformChanged) root.composeTransforms();
				trm.prepend(root.inverseTransform);
			}
			//��������� ����� � ������������ ���������� ������� ������������ 
			var res:Vector3D = new Vector3D();
			res.x = trm.a*point.x + trm.b*point.y + trm.c*point.z + trm.d;
			res.y = trm.e*point.x + trm.f*point.y + trm.g*point.z + trm.h;
			res.z = trm.i*point.x + trm.j*point.y + trm.k*point.z + trm.l;
			return res;
		}

		/** 
		 * ����������, ����� �� �� ���� ������ ��������� ����������� ��������� �����:
		 * DirectionalLight, OmniLight, SpotLight.
		 * @private 
		 */
		alternativa3d function get useLights():Boolean {return false;}

		/** ����������� ��������� ������� � ��� ������� ���������. */
		public function calculateBoundBox():void {
			//���������� ������� ��������� ����������
			if (boundBox != null) {
				boundBox.reset();
			} else {
				boundBox = new BoundBox();
			}
			//� ������������� ��
			updateBoundBox(boundBox, null);
		}

		/**
		 * ����������� ��������� ���������� �������� �������.
		 * @param	boundBox	���������, ��������� �������� ������ ���� ���������. 
		 * @param	transform	������� �������������, �� ������ ������� ����� ������������ ������� ���������� �� �����.
		 * @private
		 */
		alternativa3d function updateBoundBox(boundBox:BoundBox, transform:Transform3D = null):void {}

		/**
		 * ������������ ������ �������������� ������� �� ������� EventDispatcher ��� ��������� ��������������� ����������� � �������.
		 * @param type 				��� �������.
		 * @param listener 			������� ��������������, �������������� �������.
		 * @param useCapture  		����������, �������� �� �������������� � ���� ������� ��� � ������� ���� � � ���� ���������� �������.
		 * @param priority 			������� ���������� �������������� �������. 
		 * @param useWeakReference  ����������, �������� �� ������ �� �������������� �������� ��� �������. �� ������������.
		 */
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			if (listener == null) throw new TypeError("Parameter listener must be non-null.");
			var listeners:Object;
			//���� ��������� ������ ������������ ������� ������ � ���� �������,
			if (useCapture) {
				//�� �������� ������ �� ������ captureListeners, ������� ��� ��� ������ ����� ���������
				if (captureListeners == null) captureListeners = new Object();
				listeners = captureListeners;
			} else {
				//���� �� ��������� ������ ������������ ������� � ������� � ����������� �����,
				//�� �������� ������ �� ������ bubbleListeners, ������� ��� ��� ������ ����� ���������
				if (bubbleListeners == null) bubbleListeners = new Object();
				listeners = bubbleListeners;
			}
			//�������� ������ �� ������, ������� ������ ��� ������� ��� ������������� ���� �������
			var vector:Vector.<Function> = listeners[type];
			//���� ����� ������ ��� �� ��� ��������������� �����, �� �������������� ���
			if (vector == null) {
				vector = new Vector.<Function>();
				listeners[type] = vector;
			}
			//���� ��������� ������� (listener) ��� �� ���� ���������������� � �������,
			//�� ��������� �� � ������
			if (vector.indexOf(listener) < 0) {
				vector.push(listener);
			}
		}

		/**
		 * ������� �������������� �� ������� EventDispatcher. 
		 * @param type 			��� �������.
		 * @param listener 		��������� ������ ��������������.
		 * @param useCapture 	���������, ��� �� ��������� ��������������� ��� ���� ������� ��� ������� ���� � ���� ���������� �������.
		 */
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			if (listener == null) throw new TypeError("Parameter listener must be non-null.");
			//������������ ��� ������ ���������, � ����� �������
			var listeners:Object = useCapture ? captureListeners : bubbleListeners;
			if (listeners != null) {
				//������ � ���������-����������� ��������� ����� �������
				var vector:Vector.<Function> = listeners[type];
				if (vector != null) {
					//������� � ������� �������, ������� ������ ���������� �� ���������
					var i:int = vector.indexOf(listener);
					if (i >= 0) {
						//�������� ������� � ������� �� ���� ������� ����
						var length:int = vector.length;
						for (var j:int = i + 1; j < length; j++,i++) {
							vector[i] = vector[j];
						}
						//����������� ����� ������� �� 1, ���� ����� ������� ������ 1 
						if (length > 1) {
							vector.length = length - 1;
						} else {
							//���� ������ ������, �� ���� ��� ������� ���� �������,
							//�� ������� ������ �� �������������
							delete listeners[type];
							var key:*;
							//��������� ������� �� ���� ���� ��������� � ������� 
							//captureListeners ��� bubbleListeners
							for (key in listeners) break;
							//���� ���, ���������� � ������ �������� �������, ����������
							//��� ����������� ������������� �������
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
		 * ��������� ������� ������������������ ������������ ������� ���������� ���� � �������.
		 * @param type 	��� �������.
		 * @return 		true ���� ���� ����������� ������� ���������� ����, ����� false.
		 */
		public function hasEventListener(type:String):Boolean {
			return captureListeners != null && captureListeners[type] || bubbleListeners != null && bubbleListeners[type];
		}

		/**
		 * ��������� ������� ������������������ ������������ ������� ���������� ���� � ������� ��� � ����� �� ��� �������.
		 * @param type  ��� �������.
		 * @return 		true ���� ���� ����������� ������� ���������� ����, ����� false.
		 */
		public function willTrigger(type:String):Boolean {
			//����������� �� ���� ��������� �������� �������, � �������, ���� ��
			//� �������� captureListeners ��� bubbleListeners ������� ���������� ����.
			//���� ���� ���������� true, ����� false.
			for (var object:Object3D = this; object != null; object = object._parent) {
				if (object.captureListeners != null && object.captureListeners[type] || object.bubbleListeners != null && object.bubbleListeners[type]) return true;
			}
			return false;
		}

		/**
		 * �������� ������� � ����� �������. ��� ������������� ������� - ����������� ������ Event �� ����� 
		 * ����������� �������� target � currentTarget, ������ �������� ��������������� ������ � ��������� 
		 * - ������������ ����������� ������ Event3D.
		 * @param event ������ Event, ������������ � ����� �������.
		 * @return 		true ���� ������� ���� ������� ����������, ����� false.
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
			//������� ������ �� ���� ��������� �������� ������� � ������ branch
			for (object = this; object != null; object = object._parent) {
				branch[branchLength] = object;
				branchLength++;
			}
			// ���� � ���� �������� ���� ������������������ ������� � ������� captureListeners (���� �������),
			// �� �������� ��� �������, ��������� � ��� ������ Event3D
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
			// ���� � ���� �������� ���� ������������������ ������� � ������� bubbleListeners (������� � ����������� ����),
			// �� �������� ��� �������, ��������� � ��� ������ Event3D
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

		/** ������ �� ������������ ������ Object3D. */
		public function get parent():Object3D {return _parent;}

		/** ������� ������� ������ �� ��������. @private */
		alternativa3d function removeFromParent():void {
			if (_parent != null) {
				_parent.removeFromList(this);
				_parent = null;
			}
		}

		/**
		 * ��������� �������� ������. ������ ����������� � ����� ������. ���� ����������� ������,
		 * ������� �������� ��� �������� ������ ���������, �� ������ ��������� �� ������ �������� 
		 * ������� ����������.
		 * @param	child 	����������� �������� ������.
		 * @return 			��������� Object3D, ������������ � ��������� child.
		 */
		public function addChild(child:Object3D):Object3D {
			// ���������, ��� �� ������� ������������� ������ Object3D ��� null
			if (child == null) throw new TypeError("Parameter child must be non-null.");
			//��������� �� �������� �� ���������� ������ ������� 
			if (child == this) throw new ArgumentError("An object cannot be added as a child of itself.");
			//����������, ��� ����������� ������ �� �������� ��������� ��������
			for (var container:Object3D = _parent; container != null; container = container._parent) {
				if (container == child) throw new ArgumentError("An object cannot be added as a child to one of it's children (or children's children, etc.).");
			}
			
			//���� ����������� ������ �� ���������� � ���� ����������
			if (child._parent != this) {
				//������� ����������� ������ �� ��� ��������
				if (child._parent != null) child._parent.removeChild(child);
				//��������� ������ � ����� ������
				addToList(child);
				//��������� ������ ��� ������������ ������� �������� ������� ���������
				child._parent = this;
				//���� ����� ������ �� ���� �������, ��������� ��� ������� ���������� � ���������
				if (child.willTrigger(Event3D.ADDED)) child.dispatchEvent(new Event3D(Event3D.ADDED, true));
			} else {
				//���� ����������� ������ ��� ��������� � ���� ����������
				//������� ��� �� ������
				child = removeFromList(child);
				if (child == null) throw new ArgumentError("Cannot add child.");
				//� ��������� ������
				addToList(child);
			}
			return child;
		}

		/**
		 * ������� �������� ������. �������� parent ���������� ������� �������� �������� null.
		 * @param child ��������� �������� ������.
		 * @return 		��������� Object3D, ������������ � ��������� child.
		 */
		public function removeChild(child:Object3D):Object3D {
			// �������� ���������� � ����� ������
			if (child == null) throw new TypeError("Parameter child must be non-null.");
			if (child._parent != this) throw new ArgumentError("The supplied Object3D must be a child of the caller.");
			child = removeFromList(child);
			if (child == null) throw new ArgumentError("Cannot remove child.");
			//���� ����� ������ �� ���� �������, ��������� ��� ������� �������� �� ����������
			if (child.willTrigger(Event3D.REMOVED)) child.dispatchEvent(new Event3D(Event3D.REMOVED, true));
			child._parent = null;
			return child;
		}

		/**
		 * ��������� �������� ������. ������ ����������� � ��������� ������� � ������.
		 * @param	child ����������� �������� ������.
		 * @param	index �������, � ������� ����������� �������� ������. ���� ������� ������� �� ������ ������ ������� �������, 
		 * 				  �������� ������, ������������ �� ���� � �� ���� �������, � ��� ���� ������������� ������� ������������ 
		 *  			  �� ���� ������� ����� � ������ ��������.
		 * @return		  ��������� Object3D, ������������ � ��������� child.
		 */
		public function addChildAt(child:Object3D, index:int):Object3D {
			// �������� ���������� � ����� ������
			if (child == null) throw new TypeError("Parameter child must be non-null.");
			if (child == this) throw new ArgumentError("An object cannot be added as a child of itself.");
			if (index < 0) throw new RangeError("The supplied index is out of bounds.");
			for (var container:Object3D = _parent; container != null; container = container._parent) {
				if (container == child) throw new ArgumentError("An object cannot be added as a child to one of it's children (or children's children, etc.).");
			}
			
			//�������� ������ �� ������ ������ ������
			var current:Object3D = childrenList;
			//������� ������ � ������ �� ������� ������ ��������� ����������� ������
			for (var i:int = 0; i < index; i++) {
				if (current == null) throw new RangeError("The supplied index is out of bounds.");
				current = current.next;
			}
			
			//���� ����������� ������ �� ���������� � ���� ����������
			if (child._parent != this) {
				//������� ����������� ������ �� ��� ��������
				if (child._parent != null) child._parent.removeChild(child);
				//��������� ������ � ������ ����� current
				addToList(child, current);
				//��������� ������ ��� ������������ ������� �������� ������� ���������
				child._parent = this;
				//���� ����� ������ �� ���� �������, ��������� ��� ������� ���������� � ���������
				if (child.willTrigger(Event3D.ADDED)) child.dispatchEvent(new Event3D(Event3D.ADDED, true));
			} else {
				//���� ����������� ������ ��� ��������� � ���� ����������
				//������� ��� �� ������
				child = removeFromList(child);
				if (child == null) throw new ArgumentError("Cannot add child.");
				//� ��������� ������
				addToList(child, current);
			}
			return child;
		}

		/**
		 * ������� �������� ������ �� ��������� �������. �������� parent ���������� ������� �������� �������� null.
		 * @param index �������, �� ������� ��������� �������� ������.
		 * @return 		��������� ��������� Object3D.
		 */
		public function removeChildAt(index:int):Object3D {
			// �������� ���������� � ����� ������
			if (index < 0) throw new RangeError("The supplied index is out of bounds.");
			//�������� ������ �� ������ ������ ������
			var child:Object3D = childrenList;
			//������� ������ � ������ ������� ��������� � ��������� �������
			for (var i:int = 0; i < index; i++) {
				if (child == null) throw new RangeError("The supplied index is out of bounds.");
				child = child.next;
			}
			if (child == null) throw new RangeError("The supplied index is out of bounds.");
			// ������� ������ �� ������
			removeFromList(child);
			//���� ����� ������ �� ���� �������, ��������� ��� ������� �������� �� ����������
			if (child.willTrigger(Event3D.REMOVED)) child.dispatchEvent(new Event3D(Event3D.REMOVED, true));
			child._parent = null;
			return child;
		}
		
		/**
		 * ������� �������� ������� � ��������� ���������.
		 * @param beginIndex 	��������� �������.
		 * @param endIndex 		�������� �������.
		 */
		public function removeChildren(beginIndex:int = 0, endIndex:int = 2147483647):void {
			// �������� ���������� � ����� ������
			if (beginIndex < 0) throw new RangeError("The supplied index is out of bounds.");
			if (endIndex < beginIndex) throw new RangeError("The supplied index is out of bounds.");
			var i:int = 0;
			
			//������, ����������� � ������ ����� ����� �������� begin
			var prev:Object3D = null;
			//������� ������, ������� ��������� � ������ � ������� beginIndex
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
			
			//������� ������, ������� ��������� � ������ ����� � ������� endIndex
			var end:Object3D = null;
			if (endIndex < 2147483647) {
				end = begin;
				while (i <= endIndex) {
					if (end == null) throw new RangeError("The supplied index is out of bounds.");
					end = end.next;
					i++;
				}
			}
			//���� beginIndex ��� ����� 0,
			//�� ������ ������ �������� � ������ ����� �������� ������� �����
			//������ end, �� ���� ������ ����������� � ������ ����� ���������� ���������� �������.
			//����� ���������� ������ prev(������ ����������� ����� ������ ���������) 
			//��������� �� ������ end(������ ����� ���������� ����������) 
			if (prev != null)
				prev.next = end;
			else
				childrenList = end;
			
			// ������� ����� �� ������
			while (begin != end) {
				var next:Object3D = begin.next;
				begin.next = null;
				//���� ����� ������ �� ���� �������, ��������� ��� ������� �������� �� ����������
				if (begin.willTrigger(Event3D.REMOVED)) begin.dispatchEvent(new Event3D(Event3D.REMOVED, true));
				begin._parent = null;
				begin = next;
			}
		}
		
		/**
		 * ���������� ��������� ��������� �������, ����������� � ��������� �������.
		 * @param index ������� ��������� �������.
		 * @return 		�������� ������ ����������� � ��������� �������.
		 */
		public function getChildAt(index:int):Object3D {
			// �������� ���������� � ����� ������
			if (index < 0) throw new RangeError("The supplied index is out of bounds.");
			//����������� �� ������ ���� �� ������ �� �������, ������� ��������� �
			//��������� �������
			var current:Object3D = childrenList;
			for (var i:int = 0; i < index; i++) {
				if (current == null) throw new RangeError("The supplied index is out of bounds.");
				current = current.next;
			}
			if (current == null) throw new RangeError("The supplied index is out of bounds.");
			return current;
		}

		/**
		 * ���������� ������� ��������� �������.
		 * @param child �������� ������.
		 * @return 		������� ��������� ��������� �������.
		 */
		public function getChildIndex(child:Object3D):int {
			// �������� ���������� � ����� ������
			if (child == null) throw new TypeError("Parameter child must be non-null.");
			if (child._parent != this) throw new ArgumentError("The supplied Object3D must be a child of the caller.");
			//����� ��, ����������� �� ������, � ���� ������� ������,
			//������� �������� �������� child, ���������� ��� ������
			var index:int = 0;
			for (var current:Object3D = childrenList; current != null; current = current.next) {
				if (current == child) return index;
				index++;
			}
			throw new ArgumentError("Cannot get child index.");
		}

		/**
		 * ������������� ������� ��������� �������.
		 * @param child �������� ������.
		 * @param index ��������������� ������� �������.
		 */
		public function setChildIndex(child:Object3D, index:int):void {
			// �������� ���������� � ����� ������
			if (child == null) throw new TypeError("Parameter child must be non-null.");
			if (child._parent != this) throw new ArgumentError("The supplied Object3D must be a child of the caller.");
			if (index < 0) throw new RangeError("The supplied index is out of bounds.");
			// ������� � ������ ������, �� ������� ������ ��������� ������ child
			var current:Object3D = childrenList;
			for (var i:int = 0; i < index; i++) {
				if (current == null) throw new RangeError("The supplied index is out of bounds.");
				current = current.next;
			}
			// ������� ������ child �� ������ �����
			child = removeFromList(child);
			if (child == null) throw new ArgumentError("Cannot set child index.");
			// � ��������� �����, �� ��� ����� �������� current
			addToList(child, current);
		}

		/**
		 * ������ ������� ��� �������� ������� � ������.
		 * @param child1 ������ �������� ������.
		 * @param child2 ������ �������� ������.
		 */
		public function swapChildren(child1:Object3D, child2:Object3D):void {
			// �������� ���������� � ����� ������
			if (child1 == null || child2 == null) throw new TypeError("Parameter child must be non-null.");
			if (child1._parent != this || child2._parent != this) throw new ArgumentError("The supplied Object3D must be a child of the caller.");
			// ���� ������ child1 ��������� �� ������ child2, ��� ��������,
			// �� ����� �� ������� ���� ������ �� ������ � ��������� � ������� �������
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
					//������ �� ������� ��������� ������ child1
					var nxt:Object3D = child1.next;
					//������� ������ child1 �� ������
					removeFromList(child1);
					//��������� ����� � ���������� ��������� �� ������ child2
					addToList(child1, child2);
					//������� ������ child2 �� ������
					removeFromList(child2);
					//��������� ����� � ���������� ��������� �� ������ nxt
					addToList(child2, nxt);
				}
			}
		}

		/**
		 * ������ ������� ��� �������� ������� � ������ �� ��������� ��������.
		 * @param index1 ������� ������� ��������� �������.
		 * @param index2 ������� ������� ��������� �������.
		 */
		public function swapChildrenAt(index1:int, index2:int):void {
			// �������� ���������� � ����� ������
			if (index1 < 0 || index2 < 0) throw new RangeError("The supplied index is out of bounds.");

			if (index1 != index2) {
				// ������� ������ � ������ ����������� � ������� index1
				var i:int;
				var child1:Object3D = childrenList;
				for (i = 0; i < index1; i++) {
					if (child1 == null) throw new RangeError("The supplied index is out of bounds.");
					child1 = child1.next;
				}
				if (child1 == null) throw new RangeError("The supplied index is out of bounds.");
				
				// ������� ������ � ������ ����������� � ������� index2
				var child2:Object3D = childrenList;
				for (i = 0; i < index2; i++) {
					if (child2 == null) throw new RangeError("The supplied index is out of bounds.");
					child2 = child2.next;
				}
				if (child2 == null) throw new RangeError("The supplied index is out of bounds.");
				
				// ���� ������ child1 ��������� �� ������ child2, ��� ��������,
				// �� ����� �� ������� ���� ������ �� ������ � ��������� � ������� �������
				if (child1 != child2) {
					if (child1.next == child2) {
						removeFromList(child2);
						addToList(child2, child1);
					} else if (child2.next == child1) {
						removeFromList(child1);
						addToList(child1, child2);
					} else {
						//������ �� ������� ��������� ������ child1
						var nxt:Object3D = child1.next;
						//������� ������ child1 �� ������
						removeFromList(child1);
						//��������� ����� � ���������� ��������� �� ������ child2
						addToList(child1, child2);
						//������� ������ child2 �� ������
						removeFromList(child2);
						//��������� ����� � ���������� ��������� �� ������ nxt
						addToList(child2, nxt);
					}
				}
			}
		}

		/**
		 * ���������� �������� ������ � �������� ������. 
		 * ���� �������� � �������� ������ ���������, ����������� ������ ����������. 
		 * ���� ������ � �������� ������ �� ���������� � ����������, ����������� null.
		 * @param 	name ��� ��������� �������.
		 * @return 	�������� ������ � �������� ������.
		 */
		public function getChildByName(name:String):Object3D {
			// �������� ���������� � ����� ������
			if (name == null) throw new TypeError("Parameter name must be non-null.");
			// ����������� �� ������ ����� �������� ������� � ������� ������ � �������� ���
			// ������������� ����������� � ����� ��������.
			for (var child:Object3D = childrenList; child != null; child = child.next) {
				if (child.name == name) return child;
			}
			return null;
		}

		/**
		 * ����������, ���������� �� ��������� ������ ����� �������� �������� �������� �������.
		 * @param child �������� ������.
		 * @return		true, ���� ��������� ������ �������� ������� �������� ��� ����� �� ��� ��������, � ��������� ������ �������� false.
		 */
		public function contains(child:Object3D):Boolean {
			// �������� ���������� � ����� ������
			if (child == null) throw new TypeError("Parameter child must be non-null.");
			// ����������� �� ����� ������, � ������� ������� �������� ����� contains()
			// ��������� ��� ������ �� ��������� ������ child.
			// ���� ���� �� ����� �������� ������� �������� �������� child, ���������� true
			if (child == this) return true;
			for (var object:Object3D = childrenList; object != null; object = object.next) {
				if (object.contains(child)) return true;
			}
			return false;
		}

		/** ���������� ���������� �������� �������� �������� �������. */
		public function get numChildren():int {
			var num:int = 0;
			for (var current:Object3D = childrenList; current != null; current = current.next) num++;
			return num;
		}
		
		/**
		 * ��������� ������ � ������ ����� �������� �������.
		 * @param	child 	������, ������� ������ ���� �������� � ������.
		 * @param	item 	������, �� ������� ������ ��������� ����������� ������. 
		 */
		private function addToList(child:Object3D, item:Object3D = null):void {
			//����������� ������ ����� ��������� �� ������ item
			child.next = item;
			//���� ������ ��� �� ��� ���������������
			if (item == childrenList) {
				//�� ������ � ������ ����� ���������� ����� ����������� ������
				childrenList = child;
			} else {
				///�����, ��������� � ������ ����������� ������
				for (var current:Object3D = childrenList; current != null; current = current.next) {
					if (current.next == item) {
						current.next = child;
						break;
					}
				}
			}
		}
		
		/**
		 * ������� ������ �� ������ ����� �������� �������.
		 * @param	child 	������, ������� ������ ���� ������ �� ������.
		 * @private 
		 */
		alternativa3d function removeFromList(child:Object3D):Object3D {
			var prev:Object3D;
			for (var current:Object3D = childrenList; current != null; current = current.next) {
				//������� ������ � ������, ������� ������ ���� ������
				if (current == child) {
					//���� ��������� ������ �� �������� ������ � ������ �����,
					//�� ���������� ���������� ������ � ������ ��������� �� ������ �� ������� ���������
					//��������� ������.
					if (prev != null) {
						prev.next = current.next;
					} else {
						//���� ������ �� ������ � ������ ������ ���� ������,
						//�� ������ ������ �������� � ������ ����� �������� ������, ����� ������
						//�� ������� �������� ��������� ������
						childrenList = current.next;
					}
					//��������� ����� ���������� ������� � ������� ����� �������� �������	
					current.next = null;
					return child;
				}
				prev = current;
			}
			return null;
		}
		
		/**
		 * �������� ������� ������������ ������ �������� ��� ����, ����� � ���������� �� ����� ���� �� ��������� � ��������.
		 *
		 * @param hierarchy 	���� ����������� �� ������������� ����� �������� � �������� ��������.
		 * @param resourceType 	��� ��������, ������� ������ ���� �������.
		 * @return 				������ ����������� ��������� �������.
		 * @see flash.display.Stage3D
		 */
		public function getResources(hierarchy:Boolean = false, resourceType:Class = null):Vector.<Resource> {
			//������ � ������� ����� �������� ������ �� �������
			var res:Vector.<Resource> = new Vector.<Resource>();
			//������ Dictionary � ������� ����� �������� ������ �� �������
			var dict:Dictionary = new Dictionary();
			var count:int = 0;
			//�������� �������
			fillResources(dict, hierarchy, resourceType);
			//�������� ������� �� ������� � ������
			for (var key:* in dict) {
				res[count++] = key as Resource;
			}
			return res;
		}

		/**
		 * �������� �������, ������� ������ ���� ��������� � Context3D.
		 * @param	resources	 ������ Dictionary, � ������� ����� �������� ������ �� ��������� �������.
		 * @param	hierarchy	 ���� ����������� �� ������������� ����� �������� � �������� ��������.
		 * @param	resourceType ��� ��������, ������� ������ ���� �������.
		 * @private 
		 */
		alternativa3d function fillResources(resources:Dictionary, hierarchy:Boolean = false, resourceType:Class = null):void {
			//���� ������� ������ ���� ������� ����� � � ����� �������� �������,
			//�������� � ������� ������� ����� fillResources().
			//� ������� Object3D ������� ������� �� ����������, ������-��� �� �� ����� �� ���������,
			//�� ���������. � �������� ������� ��� ����� ���������������� ��� ����� ���������� ��������.
			if (hierarchy) {
				for (var child:Object3D = childrenList; child != null; child = child.next) {
					child.fillResources(resources, hierarchy, resourceType);
				}
			}
		}

		/** 
		 * ��������� ������� ������� ������������� ������� transform
		 * � ��������������� ������� ������������� inverseTransform.
		 * @private
		 */
		alternativa3d function composeTransforms():void {
			// �������� ������� ������������� 
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
			// �������� ��������������� ������� �������������
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

		/** ���������, ������ �� ������� ������ ����������� ��� ������������ ��� ������. @private */
		alternativa3d function calculateVisibility(camera:Camera3D):void {}

		/** ���������, ����� ���� �������� ������� ������ ���� ��������������� � ����� ���. @private */
		alternativa3d function calculateChildrenVisibility(camera:Camera3D):void {
			for (var child:Object3D = childrenList; child != null; child = child.next) {
				//���� ������ �������, �� ���������� ������������ ���.
				//���� ���������, �� ������� ��� ��� ��������� �� �����.
				if (child.visible) {
					// ��������� ������� ������������� �������, ���� ���������.
					if (child.transformChanged) child.composeTransforms();
					// ��������� ������� ��� ��������������� ��������� ������ � ��������� ���������� �������
					child.cameraToLocalTransform.combine(child.inverseTransform, cameraToLocalTransform);
					// ��������� ������� ��� ��������������� ��������� ��������� ������� � ���������� ������
					child.localToCameraTransform.combine(localToCameraTransform, child.transform);
					// ���� � ������� ������� ���������
					if (child.boundBox != null) {
						//������������ ������� ������, �������� ��� � ������������ ������� 
						camera.calculateFrustum(child.cameraToLocalTransform);
						//��������� ��������� �� ����������� � ��������� ������.
						// � �������� culling ������������ ��������� ���������.
						// 0  == ��������� ������� ��������� ��������� � �������� ��������� ������
						// 2  == ��������� ������� ������������ c ������� ���������� �������� ��������� ������
						// 4  == ��������� ������� ������������ c ����� ���������� �������� ��������� ������
						// 8  == ��������� ������� ������������ c ������ ���������� �������� ��������� ������
						// 16 == ��������� ������� ������������ c ������� ���������� �������� ��������� ������
						// 32 == ��������� ������� ������������ c ������ ���������� �������� ��������� ������
						// 48 == ��������� ������� ������������ c ������� ���������� �������� ��������� ������
						// 63 == ��������� ������� ��������� ��������� � �������� ��������� ������
						// -1 == ��������� ������� ��������� �� ��������� � �������� ��������� ������
						child.culling = child.boundBox.checkFrustumCulling(camera.frustum, 63);
					} else {
						//���� ���������� � ������� ���, ������� ����� ������ ��� ��������� ����������� � �������� ��������� ������
						child.culling = 63;
					}

					// ������ �������������� ��������, ��� ������ �� ��� ���� ����������� ������ child
					if (child.culling >= 0) child.calculateVisibility(camera);
					// �����, ����� �� ����� ������� child ������ �����������
					if (child.childrenList != null) child.calculateChildrenVisibility(camera);
				}
			}
		}

		/**
		 * �������� ������� ����������� ��� ���������� �������� �������. 
		 * @param	camera		 	������.
		 * @param	lights			��������� �����, �������������� �� ������.
		 * @param	lightsLength	���������� ���������� �����.
		 * @private
		 */
		alternativa3d function collectDraws(camera:Camera3D, lights:Vector.<Light3D>, lightsLength:int):void {}

		/**
		 * �������� ������� ����������� ��� ���������� ����� �������� �������. 
		 * @param	camera			������.
		 * @param	lights			��������� �����, �������������� �� ������.
		 * @param	lightsLength	���������� ���������� �����.
		 * @private
		 */
		alternativa3d function collectChildrenDraws(camera:Camera3D, lights:Vector.<Light3D>, lightsLength:int):void {
			var i:int;
			var light:Light3D;
			//����������� �� ������ ����� �������� �������
			for (var child:Object3D = childrenList; child != null; child = child.next) {
				//���� ������ �������, �� ���������� ������������ ���.
				//���� ���������, �� ������� ��� ��� ��������� �� �����.
				if (child.visible) {
					// ���� ������ child ��������� � �������� ������ � ��� �� ����������� ���������, �� ���������� ��� ������������
					if (child.culling >= 0 && (child.boundBox == null || camera.occludersLength == 0 || !child.boundBox.checkOcclusion(camera.occluders, camera.occludersLength, child.localToCameraTransform))) {
						// ��������� ����-������� ���� �� ����������� � ����������� �������, ���������
						// �������� ���������� � ���������� listening.
						// true == ����������� ����� � ����������� ������� , false == �� �������.
						if (child.boundBox != null) {
							//��������� ����-������� ����
							camera.calculateRays(child.cameraToLocalTransform);
							//��������� ����������� ����� � �����������
							child.listening = child.boundBox.checkRays(camera.origins, camera.directions, camera.raysLength);
						} else {
							child.listening = true;
						}
						// ���� �� ������ ������ �������������� ��������� �����
						if (lightsLength > 0 && child.useLights) {
							if (child.boundBox != null) {
								var childLightsLength:int = 0;
								for (i = 0; i < lightsLength; i++) {
									light = lights[i];
									// ��������� ������� ��� ��������������� ��������� �� ������������ ��������� �����
									// � ������������ ������� child
									light.lightToObjectTransform.combine(child.cameraToLocalTransform, light.localToCameraTransform);
									// ���������� ���������� ���������� ����� ����������� ������� �� ������� ������ child
									if (light.boundBox == null || light.checkBound(child)) {
										camera.childLights[childLightsLength] = light;
										childLightsLength++;
									}
								}
								child.collectDraws(camera, camera.childLights, childLightsLength);
							} else {
								// ��������� ������� ��� ��������������� ��������� �� ������������ ��������� �����
								// � ������������ ������� child
								for (i = 0; i < lightsLength; i++) {
									light = lights[i];
									light.lightToObjectTransform.combine(child.cameraToLocalTransform, light.localToCameraTransform);
								}
								child.collectDraws(camera, lights, lightsLength);
							}
						} else {
							child.collectDraws(camera, null, 0);
						}
						// ���� ������� ����� ����� ������, � �������� ��������� �����������, �� ������ ��������� ������� child (������ Wireframe) 
						if (camera.debug && child.boundBox != null && (camera.checkInDebug(child) & Debug.BOUNDS)) Debug.drawBoundBox(camera, child.boundBox, child.localToCameraTransform);
					}
					// �������� ������ � ����� �������� �������
					if (child.childrenList != null) child.collectChildrenDraws(camera, lights, lightsLength);
				}
			}
		}

		/**
		 * �������� ��������� �������� ������� ��� �������� ����������� ���������� � ���.
		 * @param	collider		��������� � ������� ����� �������������� �������� �� �����������. 
		 * @param	excludedObjects	������������� ������, ������� �������� �������� ���������� Object3D � ��� �����������.
		 * 							�������, ������������ � ���� ������� ����� ��������� �� ��������.
		 * @private
		 */
		alternativa3d function collectGeometry(collider:EllipsoidCollider, excludedObjects:Dictionary):void {}

		/**
		 * �������� ��������� ����� �������� ������� ��� �������� ����������� ���������� � ���.
		 * @param	collider		 ��������� � ������� ����� �������������� �������� �� �����������. 
		 * @param	excludedObjects  ������������� ������, ������� �������� �������� ���������� Object3D � ��� �����������.
		 * 							 �������, ������������ � ���� ������� ����� ��������� �� ��������.
		 * @private
		 */
		alternativa3d function collectChildrenGeometry(collider:EllipsoidCollider, excludedObjects:Dictionary):void {
			//����������� �� ������ ����� �������� �������
			for (var child:Object3D = childrenList; child != null; child = child.next) {
				//���� �������� ����������� ���������� � �������� child ����� ���� �����������
				if (excludedObjects == null || !excludedObjects[child]) {
					// ��������� ������� ������������� �������, ���� ���������
					if (child.transformChanged) child.composeTransforms();
					// ��������� ������� ��� ��������������� ��������� ���������� � ��������� ���������� �������
					child.globalToLocalTransform.combine(child.inverseTransform, globalToLocalTransform);
					// ��������� ����������� �����-���������� � ����������� �������
					var intersects:Boolean = true;
					if (child.boundBox != null) {
						collider.calculateSphere(child.globalToLocalTransform);
						intersects = child.boundBox.checkSphere(collider.sphere);
					}
					// ���� ����������� ���������� � ����������� ���� �������, ��� � ������� child �� ���
					// ��������� ���������, ������������ �������� ����������� ���������� � ���������� �������
					if (intersects) {
						// ��������� ������� ��� ��������������� ��������� ��������� ������� � ���������� ����������
						child.localToGlobalTransform.combine(localToGlobalTransform, child.transform);
						//��������� � ��������� ������ �� ��������� ������� child, � ������� ��������� ����� ������������
						//�������� �� �����������
						child.collectGeometry(collider, excludedObjects);
					}
					// ��������� ����������� ���������� � ������ ������� child
					if (child.childrenList != null) child.collectChildrenGeometry(collider, excludedObjects);
				}
			}
		}

		/** @private */
		alternativa3d function setTransformConstants(drawUnit:DrawUnit, surface:Surface, vertexShader:Linker, camera:Camera3D):void {}

		/**
		 * ���������� ����� �������.
		 * @return ����� �������.
		 */
		public function clone():Object3D {
			var res:Object3D = new Object3D();
			res.clonePropertiesFrom(this);
			return res;
		}

		/**
		 * �������� ������� ��������. ����� ���������� ������ ������ clone().
		 * @param source ������, � �������� ���������� ������� ��������.
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
			//����������� �� ������ ����� ����������� �������, � �������� �� � ������� ������
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
		 * ���������� ��������� ������������� �������� �������.
		 * @return ��������� ������������� �������.
		 */
		public function toString():String {
			var className:String = getQualifiedClassName(this);
			return "[" + className.substr(className.indexOf("::") + 2) + " " + name + "]";
		}
	}
}